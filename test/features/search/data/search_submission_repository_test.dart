import 'package:coffee_recommender/core/logging/app_logger.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/features/search/data/repositories/search_submission_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockDioClient extends Mock implements DioClient {}

class SilentLogger extends AppLogger {
  const SilentLogger();

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {}
}

void main() {
  late MockDio dio;
  late MockDioClient dioClient;
  late SearchSubmissionRepository repository;

  setUp(() {
    dio = MockDio();
    dioClient = MockDioClient();
    when(() => dioClient.dio).thenReturn(dio);
    repository = SearchSubmissionRepository(
      dioClient,
      logger: const SilentLogger(),
    );
  });

  group('SearchSubmissionRepository', () {
    test('submitReview posts review data and parses response', () async {
      when(
        () => dio.post<dynamic>(
          'shops/7/reviews',
          data: {
            'user_name': 'Linh',
            'rating': 5,
            'comment': 'Great coffee',
          },
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: _reviewJson,
          requestOptions: RequestOptions(path: 'shops/7/reviews'),
          statusCode: 201,
        ),
      );

      final review = await repository.submitReview(
        shopId: 7,
        userName: 'Linh',
        rating: 5,
        comment: 'Great coffee',
      );

      expect(review, isNotNull);
      expect(review!.userName, 'Linh');
      expect(review.rating, 5);
    });

    test('submitReview returns null when request fails', () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException.connectionError(
          requestOptions: RequestOptions(path: 'reviews'),
          reason: 'offline',
        ),
      );

      final review = await repository.submitReview(
        shopId: 7,
        userName: 'Linh',
        rating: 5,
        comment: 'Great coffee',
      );

      expect(review, isNull);
    });

    test('submitSuggestion returns true for successful response', () async {
      final suggestion = {'name': 'New Cafe'};
      when(
        () => dio.post<dynamic>(
          'suggestions',
          data: suggestion,
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: 'suggestions'),
          statusCode: 201,
        ),
      );

      final result = await repository.submitSuggestion(suggestion);

      expect(result, isTrue);
    });

    test('submitSuggestion returns false when request fails', () async {
      when(
        () => dio.post<dynamic>(
          'suggestions',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException.connectionError(
          requestOptions: RequestOptions(path: 'suggestions'),
          reason: 'offline',
        ),
      );

      final result = await repository.submitSuggestion({'name': 'New Cafe'});

      expect(result, isFalse);
    });
  });
}

const _reviewJson = {
  'id': 1,
  'user_name': 'Linh',
  'rating': 5,
  'comment': 'Great coffee',
  'created_at': '2026-05-22T00:00:00Z',
};
