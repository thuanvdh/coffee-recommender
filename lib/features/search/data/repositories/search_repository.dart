import 'package:coffee_recommender/core/network/api_error_mapper.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:dio/dio.dart';

class SearchRepository {
  SearchRepository(this._client);

  final DioClient _client;
  List<CoffeeShop> _cachedShops = const [];

  List<CoffeeShop> get cachedShops => List.unmodifiable(_cachedShops);

  Future<Result<List<CoffeeShop>>> fetchShops({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await _client.dio.get(
        'shops',
        queryParameters: queryParameters,
      );
      final shops = _parseShops(response.data);
      _cachedShops = List.unmodifiable(shops);
      return Result.success(shops);
    } on DioException catch (error) {
      return Result.failure(ApiErrorMapper.map(error));
    } catch (_) {
      return const Result.failure(AppFailure.invalidData());
    }
  }

  List<CoffeeShop> _parseShops(Object? data) {
    final rawShops = switch (data) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map when map['shops'] is List<dynamic> =>
        map['shops'] as List<dynamic>,
      final Map<String, dynamic> map when map['data'] is List<dynamic> =>
        map['data'] as List<dynamic>,
      _ => throw const FormatException('Invalid shops response'),
    };

    return rawShops
        .map((item) => CoffeeShop.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
