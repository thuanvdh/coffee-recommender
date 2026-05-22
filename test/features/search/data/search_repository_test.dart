import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/data/repositories/search_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDio dio;
  late MockDioClient dioClient;
  late SearchRepository repository;

  setUp(() {
    dio = MockDio();
    dioClient = MockDioClient();
    when(() => dioClient.dio).thenReturn(dio);
    repository = SearchRepository(dioClient);
  });

  group('SearchRepository', () {
    test('fetchShops parses list response and caches successful shops',
        () async {
      when(
        () => dio.get<dynamic>(
          'shops',
          queryParameters: {'search': 'yen'},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: [_shopJson],
          requestOptions: RequestOptions(path: 'shops'),
          statusCode: 200,
        ),
      );

      final result = await repository.fetchShops(
        queryParameters: {'search': 'yen'},
      );

      expect(result, isA<Success<List<CoffeeShop>>>());
      expect(result.valueOrNull, hasLength(1));
      expect(result.valueOrNull!.single.name, 'Goc Yen Binh');
      expect(repository.cachedShops, result.valueOrNull);
    });

    test('fetchShops parses map response with shops list', () async {
      when(
        () => dio.get<dynamic>(
          'shops',
          queryParameters: <String, dynamic>{},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: {
            'shops': [_shopJson],
          },
          requestOptions: RequestOptions(path: 'shops'),
          statusCode: 200,
        ),
      );

      final result = await repository.fetchShops(queryParameters: {});

      expect(result.valueOrNull!.single.slug, 'goc-yen-binh');
      expect(repository.cachedShops, hasLength(1));
    });

    test('fetchShops can skip caching successful shops', () async {
      when(
        () => dio.get<dynamic>(
          'shops',
          queryParameters: {'search': 'uncached'},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: [_shopJson],
          requestOptions: RequestOptions(path: 'shops'),
          statusCode: 200,
        ),
      );

      final result = await repository.fetchShops(
        queryParameters: {'search': 'uncached'},
        cacheResult: false,
      );

      expect(result.valueOrNull, hasLength(1));
      expect(repository.cachedShops, isEmpty);
    });

    test('cacheShops replaces cached shops explicitly', () {
      repository.cacheShops([CoffeeShop.fromJson(_shopJson)]);

      expect(repository.cachedShops.single.slug, 'goc-yen-binh');
    });

    test('returns mapped failure after dio error while preserving cache',
        () async {
      when(
        () => dio.get<dynamic>(
          'shops',
          queryParameters: {'search': 'cached'},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: [_shopJson],
          requestOptions: RequestOptions(path: 'shops'),
          statusCode: 200,
        ),
      );
      await repository.fetchShops(queryParameters: {'search': 'cached'});

      when(
        () => dio.get<dynamic>(
          'shops',
          queryParameters: {'search': 'offline'},
        ),
      ).thenThrow(
        DioException.connectionError(
          requestOptions: RequestOptions(path: 'shops'),
          reason: 'offline',
        ),
      );

      final result = await repository.fetchShops(
        queryParameters: {'search': 'offline'},
      );

      expect(result, isA<Failure<List<CoffeeShop>>>());
      expect(result.failureOrNull!.type, AppFailureType.network);
      expect(repository.cachedShops.single.slug, 'goc-yen-binh');
    });

    test('returns invalidData for malformed response', () async {
      when(
        () => dio.get<dynamic>(
          'shops',
          queryParameters: <String, dynamic>{},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: {'shops': 'not-list'},
          requestOptions: RequestOptions(path: 'shops'),
          statusCode: 200,
        ),
      );

      final result = await repository.fetchShops(queryParameters: {});

      expect(result.failureOrNull!.type, AppFailureType.invalidData);
      expect(repository.cachedShops, isEmpty);
    });
  });
}

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
