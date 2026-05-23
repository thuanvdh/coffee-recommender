import 'package:coffee_recommender/core/network/dio_provider.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/data/repositories/search_repository.dart';
import 'package:coffee_recommender/features/search/data/repositories/search_submission_repository.dart';
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/domain/services/search_query_builder.dart';
import 'package:coffee_recommender/features/search/domain/services/shop_ranking_service.dart';
import 'package:coffee_recommender/features/search/presentation/state/search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:coffee_recommender/features/search/presentation/state/search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(
    DioClient dioClient, {
    SearchRepository? repository,
    SearchSubmissionRepository? submissionRepository,
    SearchQueryBuilder? queryBuilder,
    ShopRankingService? rankingService,
  })  : _repository = repository ?? SearchRepository(dioClient),
        _submissionRepository =
            submissionRepository ?? SearchSubmissionRepository(dioClient),
        _queryBuilder = queryBuilder ?? SearchQueryBuilder(),
        _rankingService = rankingService ?? ShopRankingService(),
        super(SearchState.initial());

  final SearchRepository _repository;
  final SearchSubmissionRepository _submissionRepository;
  final SearchQueryBuilder _queryBuilder;
  final ShopRankingService _rankingService;
  int _searchRequestId = 0;

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

  void updateOpenNow(bool openNow) {
    state = state.copyWith(openNow: openNow);
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
    final rankingIntent = _effectiveRankingIntent(
      intent: intent,
      filter: effectiveFilter,
    );
    final requestId = ++_searchRequestId;
    state = _withCompatibilityFields(
      state.copyWith(
        status: SearchStateStatus.loading,
        intent: intent,
        filter: effectiveFilter,
        isLoading: true,
        failure: null,
        error: null,
      ),
      intent: intent,
      filter: effectiveFilter,
    );

    final queryParameters = _queryBuilder.build(
      intent: intent,
      filter: effectiveFilter,
    );
    final result = await _repository.fetchShops(
      queryParameters: Map<String, dynamic>.from(queryParameters),
      cacheResult: false,
    );
    if (requestId != _searchRequestId) {
      return;
    }

    switch (result) {
      case Success<List<CoffeeShop>>(:final value):
        _repository.cacheShops(value);
        _setSuccessfulState(
          intent: intent,
          filter: effectiveFilter,
          rankingIntent: rankingIntent,
          shops: value,
        );
      case Failure<List<CoffeeShop>>(:final failure):
        _setFailureState(
          intent: intent,
          filter: effectiveFilter,
          rankingIntent: rankingIntent,
          failure: failure,
        );
    }
  }

  void _setSuccessfulState({
    required SearchIntent intent,
    required SearchFilter filter,
    required SearchIntent rankingIntent,
    required List<CoffeeShop> shops,
  }) {
    final rankedShops = _rankingService.rank(
      shops: shops,
      intent: rankingIntent,
    );
    state = _withCompatibilityFields(
      state.copyWith(
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
      ),
      intent: intent,
      filter: filter,
    );
  }

  void _setFailureState({
    required SearchIntent intent,
    required SearchFilter filter,
    required SearchIntent rankingIntent,
    required AppFailure failure,
  }) {
    final cachedShops = _repository.cachedShops;
    if (cachedShops.isNotEmpty) {
      final rankedCachedShops = _rankingService.rank(
        shops: cachedShops,
        intent: rankingIntent,
      );
      state = _withCompatibilityFields(
        state.copyWith(
          status: SearchStateStatus.stale,
          intent: intent,
          filter: filter,
          rankedShops: rankedCachedShops,
          failure: failure,
          isLoading: false,
          shops: rankedCachedShops.map((item) => item.shop).toList(),
          error: failure.userMessage,
        ),
        intent: intent,
        filter: filter,
      );
      return;
    }

    state = _withCompatibilityFields(
      state.copyWith(
        status: SearchStateStatus.failure,
        intent: intent,
        filter: filter,
        rankedShops: const [],
        failure: failure,
        isLoading: false,
        shops: const [],
        error: failure.userMessage,
      ),
      intent: intent,
      filter: filter,
    );
  }

  SearchIntent _effectiveRankingIntent({
    required SearchIntent intent,
    required SearchFilter filter,
  }) {
    return intent.copyWith(
      district: filter.district ?? intent.district,
      purposeTags: filter.purpose == null
          ? intent.purposeTags
          : _nullableTag(filter.purpose),
      amenityTags: filter.amenity == null
          ? intent.amenityTags
          : _nullableTag(filter.amenity),
      spaceTags:
          filter.space == null ? intent.spaceTags : _nullableTag(filter.space),
      openNow: filter.openNow ?? intent.openNow,
    );
  }

  SearchState _withCompatibilityFields(
    SearchState base, {
    required SearchIntent intent,
    required SearchFilter filter,
  }) {
    return base.copyWith(
      searchQuery: intent.query,
      selectedDistrict: filter.district ?? intent.district,
      selectedPurpose: filter.purpose ?? _firstTag(intent.purposeTags),
      selectedSpace: filter.space ?? _firstTag(intent.spaceTags),
      selectedAmenity: filter.amenity ?? _firstTag(intent.amenityTags),
      openNow: filter.openNow ?? intent.openNow,
      latitude: intent.latitude,
      longitude: intent.longitude,
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
      openNow: state.openNow,
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
      openNow: state.openNow ? true : null,
    );
  }

  List<String> _nullableTag(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return const [];
    }
    return [trimmed];
  }

  String? _firstTag(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  Future<Review?> submitReview(
    int shopId,
    String userName,
    int rating,
    String comment,
  ) async {
    return _submissionRepository.submitReview(
      shopId: shopId,
      userName: userName,
      rating: rating,
      comment: comment,
    );
  }

  Future<bool> submitSuggestion(Map<String, dynamic> data) async {
    return _submissionRepository.submitSuggestion(data);
  }
}

final searchDioClientProvider = Provider<DioClient>(
  (ref) => DioClient(ref.watch(dioProvider)),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(searchDioClientProvider)),
);

final searchSubmissionRepositoryProvider = Provider<SearchSubmissionRepository>(
  (ref) => SearchSubmissionRepository(ref.watch(searchDioClientProvider)),
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
    submissionRepository: ref.watch(searchSubmissionRepositoryProvider),
    queryBuilder: ref.watch(searchQueryBuilderProvider),
    rankingService: ref.watch(shopRankingServiceProvider),
  )..fetchShops();
});
