import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/network/api_exception.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late DioClient dioClient;

  setUp(() {
    mockDio = MockDio();
    when(() => mockDio.options).thenReturn(BaseOptions());
    dioClient = DioClient(mockDio);
  });

  test('DioClient base URL is configured properly', () {
    expect(dioClient.baseUrl, contains('/api'));
  });
}
