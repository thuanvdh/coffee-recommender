import 'package:coffee_recommender/core/network/api_error_mapper.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:dio/dio.dart';

class ShopDetailRepository {
  ShopDetailRepository(this._client);

  final DioClient _client;

  Future<Result<CoffeeShop>> fetchBySlug(String slug) async {
    try {
      final response = await _client.dio.get('shops/slug/$slug');
      return Result.success(_parseShop(response.data));
    } on DioException catch (error) {
      return Result.failure(ApiErrorMapper.map(error));
    } catch (_) {
      return const Result.failure(AppFailure.invalidData());
    }
  }

  CoffeeShop _parseShop(Object? data) {
    final shopJson = switch (data) {
      final Map<String, dynamic> map when map['shop'] is Map<String, dynamic> =>
        map['shop'] as Map<String, dynamic>,
      final Map<String, dynamic> map when map['data'] is Map<String, dynamic> =>
        map['data'] as Map<String, dynamic>,
      final Map<String, dynamic> map => map,
      _ => throw const FormatException('Invalid shop detail response'),
    };

    return CoffeeShop.fromJson(shopJson);
  }
}
