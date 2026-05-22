import 'dart:async';

import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/data/repositories/search_repository.dart';
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/domain/services/search_query_builder.dart';
import 'package:coffee_recommender/features/search/domain/services/shop_ranking_service.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockDioClient dioClient;
  late MockDio dio;
  late MockSearchRepository repository;

  setUp(() {
    dioClient = MockDioClient();
    dio = MockDio();
    repository = MockSearchRepository();
    when(() => dioClient.dio).thenReturn(dio);
    when(() => repository.cachedShops).thenReturn(const []);
  });

  SearchNotifier notifier() {
    return SearchNotifier(
      dioClient,
      repository: repository,
      queryBuilder: SearchQueryBuilder(),
      rankingService: ShopRankingService(),
    );
  }

  group('SearchNotifier', () {
    test('SearchState.initial has typed and compatibility defaults', () {
      final state = SearchState.initial();

      expect(state.status, SearchStateStatus.initial);
      expect(state.intent, SearchIntent());
      expect(state.searchQuery, '');
      expect(state.selectedDistrict, isNull);
      expect(state.isLoading, false);
      expect(state.shops, isEmpty);
      expect(state.rankedShops, isEmpty);
    });

    test('successful search ranks shops and updates compatibility shops',
        () async {
      when(
        () => repository.fetchShops(
          queryParameters: {
            'purpose': 'Làm việc',
            'amenity': 'Máy lạnh',
          },
          cacheResult: false,
        ),
      ).thenAnswer((_) async => Result.success([_shop]));

      final subject = notifier();
      await subject.search(
        SearchIntent(
          purposeTags: ['Làm việc'],
          amenityTags: ['Máy lạnh'],
        ),
      );

      final state = subject.debugState;
      expect(state.status, SearchStateStatus.success);
      expect(state.isLoading, isFalse);
      expect(state.rankedShops.single.shop, _shop);
      expect(state.rankedShops.single.score, 50);
      expect(state.shops, [_shop]);
      expect(state.error, isNull);
      verify(() => repository.cacheShops([_shop])).called(1);
    });

    test('successful empty search sets empty state', () async {
      when(
        () => repository.fetchShops(
          queryParameters: <String, dynamic>{},
          cacheResult: false,
        ),
      ).thenAnswer((_) async => const Result.success([]));

      final subject = notifier();
      await subject.search(SearchIntent());

      final state = subject.debugState;
      expect(state.status, SearchStateStatus.empty);
      expect(state.isLoading, isFalse);
      expect(state.shops, isEmpty);
      expect(state.rankedShops, isEmpty);
      expect(state.error, isNull);
    });

    test('older delayed search cannot overwrite newer results', () async {
      final delayedRepository = DelayedSearchRepository(dioClient);
      final subject = SearchNotifier(
        dioClient,
        repository: delayedRepository,
        queryBuilder: SearchQueryBuilder(),
        rankingService: ShopRankingService(),
      );

      final olderSearch = subject.search(SearchIntent(query: 'old'));
      final newerSearch = subject.search(SearchIntent(query: 'new'));

      delayedRepository.completeQuery(
        'new',
        Result.success([_newerShop]),
      );
      await newerSearch;

      expect(subject.debugState.status, SearchStateStatus.success);
      expect(subject.debugState.searchQuery, 'new');
      expect(subject.debugState.shops, [_newerShop]);
      expect(delayedRepository.cachedShops, [_newerShop]);

      delayedRepository.completeQuery(
        'old',
        Result.success([_olderShop]),
      );
      await olderSearch;

      expect(subject.debugState.status, SearchStateStatus.success);
      expect(subject.debugState.searchQuery, 'new');
      expect(subject.debugState.shops, [_newerShop]);
      expect(delayedRepository.cachedShops, [_newerShop]);
    });

    test(
        'older out-of-order success cannot change cache used by later stale fallback',
        () async {
      final delayedRepository = DelayedSearchRepository(dioClient);
      final subject = SearchNotifier(
        dioClient,
        repository: delayedRepository,
        queryBuilder: SearchQueryBuilder(),
        rankingService: ShopRankingService(),
      );

      final olderSearch = subject.search(SearchIntent(query: 'old'));
      final newerSearch = subject.search(SearchIntent(query: 'new'));

      delayedRepository.completeQuery(
        'new',
        Result.success([_newerShop]),
      );
      await newerSearch;

      delayedRepository.completeQuery(
        'old',
        Result.success([_olderShop]),
      );
      await olderSearch;

      expect(delayedRepository.cachedShops, [_newerShop]);

      final failedSearch = subject.search(SearchIntent(query: 'fail'));
      delayedRepository.completeQuery(
        'fail',
        const Result.failure(AppFailure.network()),
      );
      await failedSearch;

      expect(subject.debugState.status, SearchStateStatus.stale);
      expect(subject.debugState.searchQuery, 'fail');
      expect(subject.debugState.shops, [_newerShop]);
      expect(subject.debugState.shops, isNot(contains(_olderShop)));
    });

    test('typed search populates compatibility fields from intent and filter',
        () async {
      when(
        () => repository.fetchShops(
          queryParameters: {
            'search': 'pour over',
            'purpose': 'Hẹn hò',
            'amenity': 'Ổ cắm',
            'space': 'Sân vườn',
            'district': 'Sơn Trà',
            'lat': 16.07,
            'lon': 108.22,
          },
          cacheResult: false,
        ),
      ).thenAnswer((_) async => Result.success([_shop]));

      final subject = notifier();
      await subject.search(
        SearchIntent(
          query: 'pour over',
          district: 'Hải Châu',
          purposeTags: ['Làm việc'],
          amenityTags: ['Máy lạnh'],
          spaceTags: ['Yên tĩnh'],
          nearMe: true,
          latitude: 16.07,
          longitude: 108.22,
        ),
        filter: SearchFilter(
          district: 'Sơn Trà',
          purpose: 'Hẹn hò',
          amenity: 'Ổ cắm',
          space: 'Sân vườn',
        ),
      );

      final state = subject.debugState;
      expect(state.intent.query, 'pour over');
      expect(state.filter.district, 'Sơn Trà');
      expect(state.searchQuery, 'pour over');
      expect(state.selectedDistrict, 'Sơn Trà');
      expect(state.selectedPurpose, 'Hẹn hò');
      expect(state.selectedAmenity, 'Ổ cắm');
      expect(state.selectedSpace, 'Sân vườn');
      expect(state.latitude, 16.07);
      expect(state.longitude, 108.22);
      expect(state.isLoading, isFalse);
      expect(state.shops, [_shop]);
      expect(state.error, isNull);
    });

    test('fetchShops builds compatibility intent and filter', () async {
      when(
        () => repository.fetchShops(
          queryParameters: {
            'search': 'yen',
            'purpose': 'Làm việc',
            'district': 'Hải Châu',
          },
          cacheResult: false,
        ),
      ).thenAnswer((_) async => Result.success([_shop]));

      final subject = notifier();
      subject.state = subject.state.copyWith(
        searchQuery: 'yen',
        selectedPurpose: 'Làm việc',
        selectedDistrict: 'Hải Châu',
      );

      await subject.fetchShops();

      expect(subject.debugState.status, SearchStateStatus.success);
      expect(subject.debugState.intent.query, 'yen');
      expect(subject.debugState.intent.purposeTags, ['Làm việc']);
      expect(subject.debugState.filter.district, 'Hải Châu');
      expect(subject.debugState.shops, [_shop]);
    });

    test('uses cached shops as stale state on failure', () async {
      when(() => repository.cachedShops).thenReturn([_shop]);
      when(
        () => repository.fetchShops(
          queryParameters: <String, dynamic>{},
          cacheResult: false,
        ),
      ).thenAnswer(
        (_) async => const Result.failure(AppFailure.network()),
      );

      final subject = notifier();
      await subject.search(SearchIntent());

      expect(subject.debugState.status, SearchStateStatus.stale);
      expect(subject.debugState.shops, [_shop]);
      expect(subject.debugState.failure!.type, AppFailureType.network);
    });

    test('sets failure state when request fails without cache', () async {
      when(
        () => repository.fetchShops(
          queryParameters: <String, dynamic>{},
          cacheResult: false,
        ),
      ).thenAnswer(
        (_) async => const Result.failure(AppFailure.network()),
      );

      final subject = notifier();
      await subject.search(SearchIntent());

      expect(subject.debugState.status, SearchStateStatus.failure);
      expect(subject.debugState.shops, isEmpty);
      expect(subject.debugState.error, const AppFailure.network().userMessage);
    });

    test('updateQuery changes query state and triggers fetch', () {
      when(
        () => repository.fetchShops(
          queryParameters: {'search': 'espresso'},
          cacheResult: false,
        ),
      ).thenAnswer((_) async => const Result.success([]));

      final subject = notifier();
      subject.updateQuery('espresso');

      expect(subject.debugState.searchQuery, 'espresso');
      expect(subject.debugState.status, SearchStateStatus.loading);
    });

    test('updateDistrict changes district state and triggers fetch', () {
      when(
        () => repository.fetchShops(
          queryParameters: {'district': 'Hải Châu'},
          cacheResult: false,
        ),
      ).thenAnswer((_) async => const Result.success([]));

      final subject = notifier();
      subject.updateDistrict('Hải Châu');

      expect(subject.debugState.selectedDistrict, 'Hải Châu');
      expect(subject.debugState.status, SearchStateStatus.loading);
    });
  });
}

class DelayedSearchRepository extends SearchRepository {
  DelayedSearchRepository(super.client);

  final Map<String, Completer<Result<List<CoffeeShop>>>> _completers = {};
  List<CoffeeShop> _cachedShops = const [];

  @override
  List<CoffeeShop> get cachedShops => List.unmodifiable(_cachedShops);

  @override
  Future<Result<List<CoffeeShop>>> fetchShops({
    required Map<String, dynamic> queryParameters,
    bool cacheResult = true,
  }) async {
    final query = queryParameters['search'] as String? ?? '';
    final completer = Completer<Result<List<CoffeeShop>>>();
    _completers[query] = completer;

    final result = await completer.future;
    if (cacheResult) {
      if (result case Success<List<CoffeeShop>>(:final value)) {
        cacheShops(value);
      }
    }
    return result;
  }

  @override
  void cacheShops(List<CoffeeShop> shops) {
    _cachedShops = List.unmodifiable(shops);
  }

  void completeQuery(String query, Result<List<CoffeeShop>> result) {
    final completer = _completers[query];
    if (completer == null) {
      throw StateError('No pending search for "$query".');
    }
    completer.complete(result);
  }
}

final _shop = CoffeeShop.fromJson(_shopJson);
final _olderShop = CoffeeShop.fromJson({..._shopJson, 'id': 2, 'name': 'Old'});
final _newerShop = CoffeeShop.fromJson({..._shopJson, 'id': 3, 'name': 'New'});

const _shopJson = {
  'id': 1,
  'name': 'Goc Yen Binh',
  'slug': 'goc-yen-binh',
  'status': 'open',
  'purposes': ['Làm việc'],
  'amenities': ['Máy lạnh'],
  'spaces': ['Yên tĩnh'],
  'created_at': '2026-05-22T00:00:00Z',
  'updated_at': '2026-05-22T00:00:00Z',
};
