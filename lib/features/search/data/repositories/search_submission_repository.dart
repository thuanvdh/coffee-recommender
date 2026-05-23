import 'package:coffee_recommender/core/logging/app_logger.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';

class SearchSubmissionRepository {
  SearchSubmissionRepository(
    this._client, {
    AppLogger logger = const AppLogger(),
  }) : _logger = logger;

  final DioClient _client;
  final AppLogger _logger;

  Future<Review?> submitReview({
    required int shopId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _client.dio.post<dynamic>(
        'shops/$shopId/reviews',
        data: {
          'user_name': userName,
          'rating': rating,
          'comment': comment,
        },
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        return Review.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (error, stack) {
      _logger.debug('submitReview failed', error, stack);
    }
    return null;
  }

  Future<bool> submitSuggestion(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.post<dynamic>(
        'suggestions',
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (error, stack) {
      _logger.debug('submitSuggestion failed', error, stack);
      return false;
    }
  }
}
