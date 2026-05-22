import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';

// Search State definition
class SearchState {
  final String searchQuery;
  final String? selectedDistrict;
  final String? selectedPurpose;
  final String? selectedSpace;
  final String? selectedAmenity;
  final bool isLoading;
  final List<CoffeeShop> shops;
  final String? error;

  const SearchState({
    this.searchQuery = '',
    this.selectedDistrict,
    this.selectedPurpose,
    this.selectedSpace,
    this.selectedAmenity,
    this.isLoading = false,
    this.shops = const [],
    this.error,
  });

  SearchState copyWith({
    String? searchQuery,
    String? selectedDistrict,
    String? selectedPurpose,
    String? selectedSpace,
    String? selectedAmenity,
    bool? isLoading,
    List<CoffeeShop>? shops,
    String? error,
  }) {
    return SearchState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedPurpose: selectedPurpose ?? this.selectedPurpose,
      selectedSpace: selectedSpace ?? this.selectedSpace,
      selectedAmenity: selectedAmenity ?? this.selectedAmenity,
      isLoading: isLoading ?? this.isLoading,
      shops: shops ?? this.shops,
      error: error ?? this.error,
    );
  }
}

// Search Notifier implementation
class SearchNotifier extends StateNotifier<SearchState> {
  final DioClient _dioClient;

  SearchNotifier(this._dioClient) : super(const SearchState());

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

  void clearFilters() {
    state = const SearchState();
    fetchShops();
  }

  Future<void> fetchShops() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParameters = <String, dynamic>{};
      if (state.searchQuery.isNotEmpty) {
        queryParameters['search'] = state.searchQuery;
      }
      if (state.selectedDistrict != null) {
        queryParameters['district'] = state.selectedDistrict;
      }
      if (state.selectedPurpose != null) {
        queryParameters['purpose'] = state.selectedPurpose;
      }
      if (state.selectedSpace != null) {
        queryParameters['space'] = state.selectedSpace;
      }
      if (state.selectedAmenity != null) {
        queryParameters['amenity'] = state.selectedAmenity;
      }

      final response = await _dioClient.dio.get(
        '/shops',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : response.data['data'] ?? [];
        final shopsList = data.map((json) => CoffeeShop.fromJson(json as Map<String, dynamic>)).toList();
        state = state.copyWith(shops: shopsList, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load shops');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider setup
final searchDioProvider = Provider<Dio>((ref) => Dio());
final searchDioClientProvider = Provider<DioClient>((ref) => DioClient(ref.watch(searchDioProvider)));

final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final dioClient = ref.watch(searchDioClientProvider);
  return SearchNotifier(dioClient)..fetchShops();
});
