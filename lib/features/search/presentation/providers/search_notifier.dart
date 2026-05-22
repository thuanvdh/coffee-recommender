import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/data/repositories/search_repository.dart';
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/domain/services/search_query_builder.dart';
import 'package:coffee_recommender/features/search/domain/services/shop_ranking_service.dart';
import 'package:coffee_recommender/features/search/presentation/state/search_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:coffee_recommender/features/search/presentation/state/search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(
    this._dioClient, {
    SearchRepository? repository,
    SearchQueryBuilder? queryBuilder,
    ShopRankingService? rankingService,
  })  : _repository = repository ?? SearchRepository(_dioClient),
        _queryBuilder = queryBuilder ?? SearchQueryBuilder(),
        _rankingService = rankingService ?? ShopRankingService(),
        super(SearchState.initial());

  final DioClient _dioClient;
  final SearchRepository _repository;
  final SearchQueryBuilder _queryBuilder;
  final ShopRankingService _rankingService;

  @override
  SearchState get debugState => state;

  void updateQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchShops();
  }

  void updateDistrict(String? district) {
    state = state.copyWith(selectedDistrict: district);
    fetchShops();
  }

  void updatePurpose(String? purpose) {
    state = state.copyWith(selectedPurpose: purpose);
    fetchShops();
  }

  void updateSpace(String? space) {
    state = state.copyWith(selectedSpace: space);
    fetchShops();
  }

  void updateAmenity(String? amenity) {
    state = state.copyWith(selectedAmenity: amenity);
    fetchShops();
  }

  void updateLocation(double? lat, double? lon) {
    state = state.copyWith(latitude: lat, longitude: lon);
    fetchShops();
  }

  void clearFilters() {
    state = SearchState.initial();
    fetchShops();
  }

  Future<void> fetchShops() {
    return search(_intentFromCompatibility(),
        filter: _filterFromCompatibility());
  }

  Future<void> search(SearchIntent intent, {SearchFilter? filter}) async {
    final effectiveFilter = filter ?? SearchFilter();
    state = state.copyWith(
      status: SearchStateStatus.loading,
      intent: intent,
      filter: effectiveFilter,
      isLoading: true,
      failure: null,
      error: null,
    );

    final queryParameters = _queryBuilder.build(
      intent: intent,
      filter: effectiveFilter,
    );
    final result = await _repository.fetchShops(
      queryParameters: Map<String, dynamic>.from(queryParameters),
    );

    switch (result) {
      case Success<List<CoffeeShop>>(:final value):
        _setSuccessfulState(
            intent: intent, filter: effectiveFilter, shops: value);
      case Failure<List<CoffeeShop>>(:final failure):
        _setFailureState(
            intent: intent, filter: effectiveFilter, failure: failure);
    }
  }

  void _setSuccessfulState({
    required SearchIntent intent,
    required SearchFilter filter,
    required List<CoffeeShop> shops,
  }) {
    final rankedShops = _rankingService.rank(shops: shops, intent: intent);
    state = state.copyWith(
      status: rankedShops.isEmpty
          ? SearchStateStatus.empty
          : SearchStateStatus.success,
      intent: intent,
      filter: filter,
      rankedShops: rankedShops,
      failure: null,
      isLoading: false,
      shops: rankedShops.map((item) => item.shop).toList(),
      error: null,
    );
  }

  void _setFailureState({
    required SearchIntent intent,
    required SearchFilter filter,
    required AppFailure failure,
  }) {
    final cachedShops = _repository.cachedShops;
    if (cachedShops.isNotEmpty) {
      final rankedCachedShops = _rankingService.rank(
        shops: cachedShops,
        intent: intent,
      );
      state = state.copyWith(
        status: SearchStateStatus.stale,
        intent: intent,
        filter: filter,
        rankedShops: rankedCachedShops,
        failure: failure,
        isLoading: false,
        shops: rankedCachedShops.map((item) => item.shop).toList(),
        error: failure.userMessage,
      );
      return;
    }

    state = state.copyWith(
      status: SearchStateStatus.failure,
      intent: intent,
      filter: filter,
      rankedShops: const [],
      failure: failure,
      isLoading: false,
      shops: const [],
      error: failure.userMessage,
    );
  }

  SearchIntent _intentFromCompatibility() {
    final hasLocation = state.latitude != null && state.longitude != null;
    return SearchIntent(
      query: state.searchQuery,
      district: state.selectedDistrict,
      purposeTags: _nullableTag(state.selectedPurpose),
      amenityTags: _nullableTag(state.selectedAmenity),
      spaceTags: _nullableTag(state.selectedSpace),
      nearMe: hasLocation,
      latitude: state.latitude,
      longitude: state.longitude,
    );
  }

  SearchFilter _filterFromCompatibility() {
    return SearchFilter(
      district: state.selectedDistrict,
      purpose: state.selectedPurpose,
      amenity: state.selectedAmenity,
      space: state.selectedSpace,
    );
  }

  List<String> _nullableTag(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return const [];
    }
    return [trimmed];
  }

  Future<Review?> submitReview(
    int shopId,
    String userName,
    int rating,
    String comment,
  ) async {
    try {
      final response = await _dioClient.dio.post(
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
      // ignore: avoid_print
      print('DEBUG: submitReview failed: $error\n$stack');
    }
    return null;
  }

  Future<bool> submitSuggestion(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.dio.post(
        'suggestions',
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (error, stack) {
      // ignore: avoid_print
      print('DEBUG: submitSuggestion failed: $error\n$stack');
      return false;
    }
  }
}

final searchDioProvider = Provider<Dio>((ref) => Dio());

final searchDioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.watch(searchDioProvider)),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(searchDioClientProvider)),
);

final searchQueryBuilderProvider = Provider<SearchQueryBuilder>(
  (ref) => SearchQueryBuilder(),
);

final shopRankingServiceProvider = Provider<ShopRankingService>(
  (ref) => ShopRankingService(),
);

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final dioClient = ref.watch(searchDioClientProvider);
  return SearchNotifier(
    dioClient,
    repository: ref.watch(searchRepositoryProvider),
    queryBuilder: ref.watch(searchQueryBuilderProvider),
    rankingService: ref.watch(shopRankingServiceProvider),
  )..fetchShops();
});
