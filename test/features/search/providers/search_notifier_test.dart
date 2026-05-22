import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:coffee_recommender/features/search/presentation/providers/search_notifier.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';

class MockDio extends Mock implements Dio {}
class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDio mockDio;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDio = MockDio();
    mockDioClient = MockDioClient();
    when(() => mockDioClient.dio).thenReturn(mockDio);
  });

  group('SearchNotifier Tests', () {
    test('Initial state is correct', () {
      final notifier = SearchNotifier(mockDioClient);
      final state = notifier.debugState;

      expect(state.searchQuery, '');
      expect(state.selectedDistrict, isNull);
      expect(state.isLoading, false);
      expect(state.shops, isEmpty);
    });

    test('updateQuery changes query state', () {
      final notifier = SearchNotifier(mockDioClient);
      notifier.updateQuery('espresso');
      expect(notifier.debugState.searchQuery, 'espresso');
    });

    test('updateDistrict changes district state', () {
      final notifier = SearchNotifier(mockDioClient);
      notifier.updateDistrict('Hải Châu');
      expect(notifier.debugState.selectedDistrict, 'Hải Châu');
    });
  });
}
