import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/data/repositories/search_repository.dart';
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
    });

    test('fetchShops builds compatibility intent and filter', () async {
      when(
        () => repository.fetchShops(
          queryParameters: {
            'search': 'yen',
            'purpose': 'Làm việc',
            'district': 'Hải Châu',
          },
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
        () => repository.fetchShops(queryParameters: <String, dynamic>{}),
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
        () => repository.fetchShops(queryParameters: <String, dynamic>{}),
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
        () => repository.fetchShops(queryParameters: {'search': 'espresso'}),
      ).thenAnswer((_) async => const Result.success([]));

      final subject = notifier();
      subject.updateQuery('espresso');

      expect(subject.debugState.searchQuery, 'espresso');
      expect(subject.debugState.status, SearchStateStatus.loading);
    });

    test('updateDistrict changes district state and triggers fetch', () {
      when(
        () => repository.fetchShops(queryParameters: {'district': 'Hải Châu'}),
      ).thenAnswer((_) async => const Result.success([]));

      final subject = notifier();
      subject.updateDistrict('Hải Châu');

      expect(subject.debugState.selectedDistrict, 'Hải Châu');
      expect(subject.debugState.status, SearchStateStatus.loading);
    });
  });
}

final _shop = CoffeeShop.fromJson(_shopJson);

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
