import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/ranked_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';

const _unset = Object();

enum SearchStateStatus {
  initial,
  loading,
  success,
  empty,
  failure,
  stale,
}

class SearchState {
  SearchState({
    this.status = SearchStateStatus.initial,
    SearchIntent? intent,
    SearchFilter? filter,
    List<RankedShop> rankedShops = const [],
    this.failure,
    this.searchQuery = '',
    this.selectedDistrict,
    this.selectedPurpose,
    this.selectedSpace,
    this.selectedAmenity,
    this.latitude,
    this.longitude,
    this.isLoading = false,
    List<CoffeeShop> shops = const [],
    this.error,
  })  : intent = intent ?? SearchIntent(),
        filter = filter ?? SearchFilter(),
        rankedShops = List.unmodifiable(rankedShops),
        shops = List.unmodifiable(shops);

  factory SearchState.initial() => SearchState();

  final SearchStateStatus status;
  final SearchIntent intent;
  final SearchFilter filter;
  final List<RankedShop> rankedShops;
  final AppFailure? failure;

  final String searchQuery;
  final String? selectedDistrict;
  final String? selectedPurpose;
  final String? selectedSpace;
  final String? selectedAmenity;
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final List<CoffeeShop> shops;
  final String? error;

  SearchState copyWith({
    SearchStateStatus? status,
    SearchIntent? intent,
    SearchFilter? filter,
    List<RankedShop>? rankedShops,
    Object? failure = _unset,
    String? searchQuery,
    Object? selectedDistrict = _unset,
    Object? selectedPurpose = _unset,
    Object? selectedSpace = _unset,
    Object? selectedAmenity = _unset,
    Object? latitude = _unset,
    Object? longitude = _unset,
    bool? isLoading,
    List<CoffeeShop>? shops,
    Object? error = _unset,
  }) {
    return SearchState(
      status: status ?? this.status,
      intent: intent ?? this.intent,
      filter: filter ?? this.filter,
      rankedShops: rankedShops ?? this.rankedShops,
      failure: failure == _unset ? this.failure : failure as AppFailure?,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDistrict: selectedDistrict == _unset
          ? this.selectedDistrict
          : selectedDistrict as String?,
      selectedPurpose: selectedPurpose == _unset
          ? this.selectedPurpose
          : selectedPurpose as String?,
      selectedSpace: selectedSpace == _unset
          ? this.selectedSpace
          : selectedSpace as String?,
      selectedAmenity: selectedAmenity == _unset
          ? this.selectedAmenity
          : selectedAmenity as String?,
      latitude: latitude == _unset ? this.latitude : latitude as double?,
      longitude: longitude == _unset ? this.longitude : longitude as double?,
      isLoading: isLoading ?? this.isLoading,
      shops: shops ?? this.shops,
      error: error == _unset ? this.error : error as String?,
    );
  }
}
