import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';
import 'package:coffee_recommender/features/home/presentation/screens/home_screen.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class FakeSearchNotifier extends SearchNotifier {
  FakeSearchNotifier() : super(DioClient(Dio())) {
    state = SearchState(
      shops: [],
      isLoading: false,
    );
  }

  @override
  Future<void> fetchShops() async {
    // Do nothing in tests to avoid actual async network calls
  }
}

List<Override> getTestOverrides() {
  return [
    weatherProvider.overrideWith((ref) async => {'temp': 28.5, 'code': 1}),
    searchNotifierProvider.overrideWith((ref) => FakeSearchNotifier()),
  ];
}
