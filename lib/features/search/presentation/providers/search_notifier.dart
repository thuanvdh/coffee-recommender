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
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final List<CoffeeShop> shops;
  final String? error;

  const SearchState({
    this.searchQuery = '',
    this.selectedDistrict,
    this.selectedPurpose,
    this.selectedSpace,
    this.selectedAmenity,
    this.latitude,
    this.longitude,
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
    double? latitude,
    double? longitude,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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

  void updateLocation(double? lat, double? lon) {
    state = state.copyWith(latitude: lat, longitude: lon);
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
      if (state.latitude != null && state.longitude != null) {
        queryParameters['lat'] = state.latitude;
        queryParameters['lon'] = state.longitude;
      }

      final response = await _dioClient.dio.get(
        'shops',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List 
            ? response.data 
            : response.data['shops'] ?? response.data['data'] ?? [];
        final shopsList = data.map((json) => CoffeeShop.fromJson(json as Map<String, dynamic>)).toList();
        state = state.copyWith(shops: shopsList, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load shops');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Review?> submitReview(int shopId, String userName, int rating, String comment) async {
    try {
      final response = await _dioClient.dio.post(
        'shops/$shopId/reviews',
        data: {
          'user_name': userName,
          'rating': rating,
          'comment': comment,
        },
      );
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return Review.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      // log or handle error
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
    } catch (e) {
      return false;
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
