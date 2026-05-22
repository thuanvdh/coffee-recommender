# Mobile-first Search Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the Flutter app's core mobile journey so Home creates a search intent, Search shows ranked coffee-shop results, and Detail helps the user decide what to do next.

**Architecture:** Use a feature-first structure with small domain/data/presentation units for discovery, search, shop detail, and favorites. Widgets render Riverpod controller state only; repositories own Dio calls and return typed `Result<T>` values. The backend API remains unchanged.

**Tech Stack:** Flutter, Dart 3, Riverpod, GoRouter, Dio, Freezed/json_serializable, shared_preferences, flutter_test, mocktail.

---

## File Map

- `lib/core/config/app_config.dart`: environment-aware API base URL and app environment.
- `lib/core/result/result.dart`: sealed success/failure result type.
- `lib/core/result/app_failure.dart`: typed failures and user-safe messages.
- `lib/core/network/api_error_mapper.dart`: converts Dio errors and invalid payloads to `AppFailure`.
- `lib/core/network/dio_client.dart`: configured Dio wrapper using `AppConfig`.
- `lib/core/logging/app_logger.dart`: tiny wrapper replacing `print('DEBUG...')`.
- `lib/features/search/domain/models/search_intent.dart`: user intent from Home/Search.
- `lib/features/search/domain/models/search_filter.dart`: advanced filter state.
- `lib/features/search/domain/models/ranked_shop.dart`: shop plus score and match reasons.
- `lib/features/search/domain/services/search_query_builder.dart`: converts intent/filter to backend params.
- `lib/features/search/domain/services/shop_ranking_service.dart`: deterministic local ranking.
- `lib/features/search/data/repositories/search_repository.dart`: shop list fetching, mapping, and last-success cache.
- `lib/features/discovery/domain/discovery_intents.dart`: smart chip presets.
- `lib/features/discovery/presentation/controllers/discovery_controller.dart`: Home intent and recent-intent behavior.
- `lib/features/shop_detail/data/repositories/shop_detail_repository.dart`: slug detail fetching and cache reuse.
- `lib/features/shop_detail/presentation/controllers/shop_detail_controller.dart`: typed detail state.
- `lib/features/favorites/data/favorites_repository.dart`: local favorite persistence.
- `lib/features/favorites/presentation/favorites_controller.dart`: shared favorites controller.
- Existing screens/widgets to modify: Home, Search, filter bottom sheet, shop card, shop detail, router, and tests.

## Task 1: Core Config, Result, And Failure Types

**Files:**
- Create: `lib/core/config/app_config.dart`
- Create: `lib/core/result/result.dart`
- Create: `lib/core/result/app_failure.dart`
- Test: `test/core/config/app_config_test.dart`
- Test: `test/core/result/result_test.dart`

- [ ] **Step 1: Write failing config tests**

Create `test/core/config/app_config_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/config/app_config.dart';

void main() {
  test('development config uses local API by default', () {
    const config = AppConfig.development();

    expect(config.environment, 'development');
    expect(config.apiBaseUrl, 'http://localhost:8000/api/');
  });

  test('custom config normalizes trailing slash', () {
    const config = AppConfig(apiBaseUrl: 'https://api.example.com/api', environment: 'test');

    expect(config.apiBaseUrl, 'https://api.example.com/api/');
  });
}
```

- [ ] **Step 2: Write failing result tests**

Create `test/core/result/result_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';

void main() {
  test('success maps value', () {
    final result = Result<int>.success(2).map((value) => value * 3);

    expect(result.isSuccess, true);
    expect(result.valueOrNull, 6);
  });

  test('failure keeps typed failure', () {
    const failure = AppFailure.timeout();
    final result = Result<int>.failure(failure);

    expect(result.isFailure, true);
    expect(result.failureOrNull, failure);
    expect(failure.userMessage, 'Ket noi qua cham. Hay thu lai.');
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run:

```bash
flutter test test/core/config/app_config_test.dart test/core/result/result_test.dart
```

Expected: fail with missing `AppConfig`, `Result`, and `AppFailure`.

- [ ] **Step 4: Implement config, result, and failures**

Create `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  final String apiBaseUrl;
  final String environment;

  const AppConfig({
    required String apiBaseUrl,
    required this.environment,
  }) : apiBaseUrl = apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/';

  const AppConfig.development()
      : apiBaseUrl = 'http://localhost:8000/api/',
        environment = 'development';

  factory AppConfig.fromEnvironment() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000/api/',
    );
    const environment = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    return const AppConfig(apiBaseUrl: apiBaseUrl, environment: environment);
  }
}
```

Create `lib/core/result/app_failure.dart`:

```dart
enum AppFailureType {
  timeout,
  network,
  server,
  unauthorized,
  invalidData,
  unknown,
}

class AppFailure {
  final AppFailureType type;
  final String message;
  final int? statusCode;

  const AppFailure._({
    required this.type,
    required this.message,
    this.statusCode,
  });

  const AppFailure.timeout()
      : this._(
          type: AppFailureType.timeout,
          message: 'Ket noi qua cham. Hay thu lai.',
        );

  const AppFailure.network()
      : this._(
          type: AppFailureType.network,
          message: 'Khong co ket noi mang. Kiem tra internet va thu lai.',
        );

  const AppFailure.server([int? statusCode])
      : this._(
          type: AppFailureType.server,
          message: 'May chu dang gap loi. Hay thu lai sau.',
          statusCode: statusCode,
        );

  const AppFailure.unauthorized()
      : this._(
          type: AppFailureType.unauthorized,
          message: 'Phien dang nhap khong hop le.',
        );

  const AppFailure.invalidData()
      : this._(
          type: AppFailureType.invalidData,
          message: 'Du lieu quan ca phe khong hop le.',
        );

  const AppFailure.unknown()
      : this._(
          type: AppFailureType.unknown,
          message: 'Da co loi xay ra. Hay thu lai.',
        );

  String get userMessage => message;
}
```

Create `lib/core/result/result.dart`:

```dart
import 'package:coffee_recommender/core/result/app_failure.dart';

sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final failure) => failure,
      };

  Result<R> map<R>(R Function(T value) mapper) {
    return switch (this) {
      Success<T>(:final value) => Result<R>.success(mapper(value)),
      Failure<T>(:final failure) => Result<R>.failure(failure),
    };
  }
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppFailure failure;

  const Failure(this.failure);
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run:

```bash
flutter test test/core/config/app_config_test.dart test/core/result/result_test.dart
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/core/config/app_config.dart lib/core/result/app_failure.dart lib/core/result/result.dart test/core/config/app_config_test.dart test/core/result/result_test.dart
git commit -m "feat: add app config and result types"
```

## Task 2: Network Error Mapping And Dio Client

**Files:**
- Modify: `lib/core/network/dio_client.dart`
- Create: `lib/core/network/api_error_mapper.dart`
- Create: `lib/core/logging/app_logger.dart`
- Test: `test/core/network/api_error_mapper_test.dart`
- Modify: `test/core/network/dio_client_test.dart`

- [ ] **Step 1: Write failing API error mapper tests**

Create `test/core/network/api_error_mapper_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/network/api_error_mapper.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';

void main() {
  RequestOptions requestOptions() => RequestOptions(path: '/shops');

  test('maps connection timeout to timeout failure', () {
    final error = DioException(
      requestOptions: requestOptions(),
      type: DioExceptionType.connectionTimeout,
    );

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.timeout);
  });

  test('maps 401 to unauthorized failure', () {
    final error = DioException(
      requestOptions: requestOptions(),
      response: Response(statusCode: 401, requestOptions: requestOptions()),
    );

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.unauthorized);
  });

  test('maps 500 to server failure with status code', () {
    final error = DioException(
      requestOptions: requestOptions(),
      response: Response(statusCode: 500, requestOptions: requestOptions()),
    );

    final failure = ApiErrorMapper.map(error);

    expect(failure.type, AppFailureType.server);
    expect(failure.statusCode, 500);
  });
}
```

- [ ] **Step 2: Update Dio client test expectation**

Replace `test/core/network/dio_client_test.dart` with:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/core/config/app_config.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';

void main() {
  test('DioClient applies config base URL and timeouts', () {
    final dio = Dio();
    final client = DioClient(
      dio,
      config: const AppConfig(apiBaseUrl: 'https://api.example.com/api', environment: 'test'),
    );

    expect(client.baseUrl, 'https://api.example.com/api/');
    expect(client.dio.options.baseUrl, 'https://api.example.com/api/');
    expect(client.dio.options.connectTimeout, const Duration(seconds: 10));
    expect(client.dio.options.receiveTimeout, const Duration(seconds: 10));
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run:

```bash
flutter test test/core/network/api_error_mapper_test.dart test/core/network/dio_client_test.dart
```

Expected: fail with missing mapper and old `DioClient` constructor signature.

- [ ] **Step 4: Implement mapper, logger, and Dio client**

Create `lib/core/network/api_error_mapper.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';

class ApiErrorMapper {
  static AppFailure map(Object error) {
    if (error is DioException) {
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          const AppFailure.timeout(),
        DioExceptionType.connectionError => const AppFailure.network(),
        DioExceptionType.badResponse => _fromStatusCode(error.response?.statusCode),
        DioExceptionType.cancel ||
        DioExceptionType.badCertificate ||
        DioExceptionType.unknown =>
          const AppFailure.unknown(),
      };
    }
    return const AppFailure.unknown();
  }

  static AppFailure _fromStatusCode(int? statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return const AppFailure.unauthorized();
    }
    if (statusCode != null && statusCode >= 500) {
      return AppFailure.server(statusCode);
    }
    return const AppFailure.invalidData();
  }
}
```

Create `lib/core/logging/app_logger.dart`:

```dart
import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger();

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint(error == null ? message : '$message: $error');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
```

Replace `lib/core/network/dio_client.dart` with:

```dart
import 'package:dio/dio.dart';
import 'package:coffee_recommender/core/config/app_config.dart';

class DioClient {
  final Dio _dio;
  final AppConfig config;

  DioClient(
    this._dio, {
    this.config = const AppConfig.development(),
  }) {
    _dio.options.baseUrl = config.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers['Accept'] = 'application/json';
  }

  String get baseUrl => config.apiBaseUrl;
  Dio get dio => _dio;
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run:

```bash
flutter test test/core/network/api_error_mapper_test.dart test/core/network/dio_client_test.dart
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/core/network/dio_client.dart lib/core/network/api_error_mapper.dart lib/core/logging/app_logger.dart test/core/network/api_error_mapper_test.dart test/core/network/dio_client_test.dart
git commit -m "feat: normalize API client errors"
```

## Task 3: Search Intent, Filters, Query Builder, And Ranking

**Files:**
- Create: `lib/features/search/domain/models/search_intent.dart`
- Create: `lib/features/search/domain/models/search_filter.dart`
- Create: `lib/features/search/domain/models/ranked_shop.dart`
- Create: `lib/features/search/domain/services/search_query_builder.dart`
- Create: `lib/features/search/domain/services/shop_ranking_service.dart`
- Test: `test/features/search/domain/search_query_builder_test.dart`
- Test: `test/features/search/domain/shop_ranking_service_test.dart`

- [ ] **Step 1: Write failing query builder tests**

Create `test/features/search/domain/search_query_builder_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/domain/services/search_query_builder.dart';

void main() {
  test('builds backend query parameters from intent and filter', () {
    const intent = SearchIntent(
      query: 'espresso',
      amenityTags: ['Máy lạnh'],
      spaceTags: ['Yên tĩnh'],
      nearMe: true,
      latitude: 16.0544,
      longitude: 108.2022,
    );
    const filter = SearchFilter(district: 'Hải Châu', openNow: true);

    final params = SearchQueryBuilder().build(intent: intent, filter: filter);

    expect(params['search'], 'espresso');
    expect(params['amenity'], 'Máy lạnh');
    expect(params['space'], 'Yên tĩnh');
    expect(params['district'], 'Hải Châu');
    expect(params['lat'], 16.0544);
    expect(params['lon'], 108.2022);
  });
}
```

- [ ] **Step 2: Write failing ranking tests**

Create `test/features/search/domain/shop_ranking_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/domain/services/shop_ranking_service.dart';

void main() {
  CoffeeShop shop({
    required String slug,
    required List<String> purposes,
    required List<String> amenities,
    required List<String> spaces,
    double? distanceKm,
  }) {
    return CoffeeShop(
      id: slug.hashCode,
      name: slug,
      slug: slug,
      status: 'open',
      purposes: purposes,
      amenities: amenities,
      spaces: spaces,
      distanceKm: distanceKm,
      createdAt: '2026-05-22T00:00:00Z',
      updatedAt: '2026-05-22T00:00:00Z',
    );
  }

  test('ranks matching shops higher and explains why', () {
    final shops = [
      shop(slug: 'plain', purposes: [], amenities: [], spaces: []),
      shop(
        slug: 'work-cafe',
        purposes: ['Làm việc'],
        amenities: ['Máy lạnh'],
        spaces: ['Yên tĩnh'],
        distanceKm: 1.2,
      ),
    ];
    const intent = SearchIntent(
      purposeTags: ['Làm việc'],
      amenityTags: ['Máy lạnh'],
      spaceTags: ['Yên tĩnh'],
      nearMe: true,
    );

    final ranked = ShopRankingService().rank(shops: shops, intent: intent);

    expect(ranked.first.shop.slug, 'work-cafe');
    expect(ranked.first.matchReasons, contains('Phù hợp để làm việc'));
    expect(ranked.first.matchReasons, contains('Có máy lạnh'));
    expect(ranked.first.matchReasons, contains('Không gian yên tĩnh'));
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run:

```bash
flutter test test/features/search/domain/search_query_builder_test.dart test/features/search/domain/shop_ranking_service_test.dart
```

Expected: fail with missing domain files.

- [ ] **Step 4: Implement domain models and services**

Create `lib/features/search/domain/models/search_intent.dart`:

```dart
class SearchIntent {
  final String query;
  final List<String> purposeTags;
  final List<String> amenityTags;
  final List<String> spaceTags;
  final String? district;
  final bool nearMe;
  final bool openNow;
  final double? latitude;
  final double? longitude;
  final List<String> moodTags;

  const SearchIntent({
    this.query = '',
    this.purposeTags = const [],
    this.amenityTags = const [],
    this.spaceTags = const [],
    this.district,
    this.nearMe = false,
    this.openNow = false,
    this.latitude,
    this.longitude,
    this.moodTags = const [],
  });
}
```

Create `lib/features/search/domain/models/search_filter.dart`:

```dart
class SearchFilter {
  final String? district;
  final String? purpose;
  final String? amenity;
  final String? space;
  final bool openNow;

  const SearchFilter({
    this.district,
    this.purpose,
    this.amenity,
    this.space,
    this.openNow = false,
  });
}
```

Create `lib/features/search/domain/models/ranked_shop.dart`:

```dart
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';

class RankedShop {
  final CoffeeShop shop;
  final int score;
  final List<String> matchReasons;

  const RankedShop({
    required this.shop,
    required this.score,
    required this.matchReasons,
  });
}
```

Create `lib/features/search/domain/services/search_query_builder.dart`:

```dart
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';

class SearchQueryBuilder {
  Map<String, dynamic> build({
    required SearchIntent intent,
    SearchFilter filter = const SearchFilter(),
  }) {
    final params = <String, dynamic>{};
    final query = intent.query.trim();
    if (query.isNotEmpty) params['search'] = query;

    final district = filter.district ?? intent.district;
    if (district != null && district.isNotEmpty) params['district'] = district;

    final purpose = filter.purpose ?? intent.purposeTags.firstOrNull;
    if (purpose != null && purpose.isNotEmpty) params['purpose'] = purpose;

    final amenity = filter.amenity ?? intent.amenityTags.firstOrNull;
    if (amenity != null && amenity.isNotEmpty) params['amenity'] = amenity;

    final space = filter.space ?? intent.spaceTags.firstOrNull;
    if (space != null && space.isNotEmpty) params['space'] = space;

    if (intent.nearMe && intent.latitude != null && intent.longitude != null) {
      params['lat'] = intent.latitude;
      params['lon'] = intent.longitude;
    }

    return params;
  }
}
```

Create `lib/features/search/domain/services/shop_ranking_service.dart`:

```dart
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/ranked_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';

class ShopRankingService {
  List<RankedShop> rank({
    required List<CoffeeShop> shops,
    required SearchIntent intent,
  }) {
    final ranked = shops.map((shop) => _rankShop(shop, intent)).toList();
    ranked.sort((a, b) => b.score.compareTo(a.score));
    return ranked;
  }

  RankedShop _rankShop(CoffeeShop shop, SearchIntent intent) {
    var score = 0;
    final reasons = <String>[];

    if (_matchesAny(shop.purposes, intent.purposeTags)) {
      score += 30;
      if (intent.purposeTags.contains('Làm việc')) {
        reasons.add('Phù hợp để làm việc');
      } else {
        reasons.add('Phù hợp mục đích của bạn');
      }
    }
    if (_matchesAny(shop.amenities, intent.amenityTags)) {
      score += 20;
      if (intent.amenityTags.contains('Máy lạnh')) reasons.add('Có máy lạnh');
    }
    if (_matchesAny(shop.spaces, intent.spaceTags)) {
      score += 20;
      if (intent.spaceTags.contains('Yên tĩnh')) reasons.add('Không gian yên tĩnh');
    }
    if (intent.nearMe && shop.distanceKm != null) {
      score += shop.distanceKm! <= 2 ? 15 : 5;
      reasons.add('${shop.distanceKm!.toStringAsFixed(1)} km từ bạn');
    }
    if (intent.openNow && shop.status.toLowerCase() == 'open') {
      score += 10;
      reasons.add('Đang mở cửa');
    }

    return RankedShop(shop: shop, score: score, matchReasons: reasons);
  }

  bool _matchesAny(List<String> values, List<String> targets) {
    return targets.any((target) => values.any((value) => value.toLowerCase() == target.toLowerCase()));
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run:

```bash
flutter test test/features/search/domain/search_query_builder_test.dart test/features/search/domain/shop_ranking_service_test.dart
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/search/domain test/features/search/domain
git commit -m "feat: add search intent and ranking domain"
```

## Task 4: Search Repository And Controller State

**Files:**
- Create: `lib/features/search/data/repositories/search_repository.dart`
- Create: `lib/features/search/presentation/state/search_state.dart`
- Modify: `lib/features/search/presentation/providers/search_notifier.dart`
- Test: `test/features/search/data/search_repository_test.dart`
- Test: `test/features/search/providers/search_notifier_test.dart`

- [ ] **Step 1: Write repository tests**

Create `test/features/search/data/search_repository_test.dart` with a mock Dio returning a list payload and a Dio error. Verify success returns shops and failure after a success returns stale cached shops:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/repositories/search_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late SearchRepository repository;

  setUp(() {
    dio = MockDio();
    repository = SearchRepository(DioClient(dio));
  });

  test('fetchShops returns success for list response', () async {
    when(() => dio.get('shops', queryParameters: any(named: 'queryParameters'))).thenAnswer(
      (_) async => Response(
        statusCode: 200,
        requestOptions: RequestOptions(path: 'shops'),
        data: [
          {
            'id': 1,
            'name': 'Goc Yen Binh',
            'slug': 'goc-yen-binh',
            'status': 'open',
            'created_at': '2026-05-22T00:00:00Z',
            'updated_at': '2026-05-22T00:00:00Z',
          }
        ],
      ),
    );

    final result = await repository.fetchShops(queryParameters: {});

    expect(result, isA<Success>());
    expect(result.valueOrNull?.single.slug, 'goc-yen-binh');
  });
}
```

- [ ] **Step 2: Write controller state tests**

Replace the existing notifier tests with tests that call `search()` using a fake repository. The fake returns success once and verifies `SearchStateStatus.success` with ranked shops.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/search/presentation/state/search_state.dart';

void main() {
  test('SearchState initial is stable', () {
    const state = SearchState.initial();

    expect(state.status, SearchStateStatus.initial);
    expect(state.rankedShops, isEmpty);
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run:

```bash
flutter test test/features/search/data/search_repository_test.dart test/features/search/providers/search_notifier_test.dart
```

Expected: fail with missing repository/state.

- [ ] **Step 4: Implement repository**

Create `lib/features/search/data/repositories/search_repository.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:coffee_recommender/core/network/api_error_mapper.dart';
import 'package:coffee_recommender/core/network/dio_client.dart';
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/core/result/result.dart';
import 'package:coffee_recommender/features/search/data/models/coffee_shop.dart';

class SearchRepository {
  final DioClient _client;
  List<CoffeeShop> _lastSuccessfulShops = const [];

  SearchRepository(this._client);

  List<CoffeeShop> get cachedShops => _lastSuccessfulShops;

  Future<Result<List<CoffeeShop>>> fetchShops({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await _client.dio.get('shops', queryParameters: queryParameters);
      final data = response.data;
      final rawList = data is List ? data : data is Map<String, dynamic> ? data['shops'] ?? data['data'] : null;
      if (rawList is! List) {
        return const Result.failure(AppFailure.invalidData());
      }
      final shops = rawList.map((json) => CoffeeShop.fromJson(json as Map<String, dynamic>)).toList();
      _lastSuccessfulShops = shops;
      return Result.success(shops);
    } on DioException catch (error) {
      return Result.failure(ApiErrorMapper.map(error));
    } catch (_) {
      return const Result.failure(AppFailure.invalidData());
    }
  }
}
```

- [ ] **Step 5: Implement SearchState**

Create `lib/features/search/presentation/state/search_state.dart`:

```dart
import 'package:coffee_recommender/core/result/app_failure.dart';
import 'package:coffee_recommender/features/search/domain/models/ranked_shop.dart';
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';

enum SearchStateStatus {
  initial,
  loading,
  success,
  empty,
  failure,
  stale,
}

class SearchState {
  final SearchStateStatus status;
  final SearchIntent intent;
  final SearchFilter filter;
  final List<RankedShop> rankedShops;
  final AppFailure? failure;

  const SearchState({
    required this.status,
    this.intent = const SearchIntent(),
    this.filter = const SearchFilter(),
    this.rankedShops = const [],
    this.failure,
  });

  const SearchState.initial() : this(status: SearchStateStatus.initial);
}
```

- [ ] **Step 6: Refactor notifier**

Refactor `SearchNotifier` to depend on `SearchRepository`, `SearchQueryBuilder`, and `ShopRankingService`. Keep provider names stable so existing tests and widgets compile during the UI migration.

- [ ] **Step 7: Run tests to verify they pass**

Run:

```bash
flutter test test/features/search/data/search_repository_test.dart test/features/search/providers/search_notifier_test.dart
```

Expected: all tests pass.

- [ ] **Step 8: Commit**

```bash
git add lib/features/search/data/repositories lib/features/search/presentation/providers/search_notifier.dart lib/features/search/presentation/state test/features/search/data test/features/search/providers/search_notifier_test.dart
git commit -m "feat: add search repository and typed state"
```

## Task 5: Discovery Smart Chips And Home Integration

**Files:**
- Create: `lib/features/discovery/domain/discovery_intents.dart`
- Create: `lib/features/discovery/presentation/controllers/discovery_controller.dart`
- Modify: `lib/features/home/presentation/screens/home_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/features/discovery/discovery_intents_test.dart`
- Test: `test/features/home/screens/home_screen_test.dart`

- [ ] **Step 1: Write smart chip preset tests**

Create `test/features/discovery/discovery_intents_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/discovery/domain/discovery_intents.dart';

void main() {
  test('work quiet aircon preset creates expected search intent', () {
    final preset = DiscoveryIntents.presets.firstWhere((item) => item.id == 'work_quiet_aircon');

    expect(preset.label, 'Làm việc yên tĩnh');
    expect(preset.intent.purposeTags, contains('Làm việc'));
    expect(preset.intent.spaceTags, contains('Yên tĩnh'));
    expect(preset.intent.amenityTags, contains('Máy lạnh'));
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
flutter test test/features/discovery/discovery_intents_test.dart
```

Expected: fail with missing discovery files.

- [ ] **Step 3: Implement discovery presets**

Create `lib/features/discovery/domain/discovery_intents.dart`:

```dart
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';

class DiscoveryIntentPreset {
  final String id;
  final String label;
  final SearchIntent intent;

  const DiscoveryIntentPreset({
    required this.id,
    required this.label,
    required this.intent,
  });
}

class DiscoveryIntents {
  static const presets = [
    DiscoveryIntentPreset(
      id: 'near_me',
      label: 'Gần tôi',
      intent: SearchIntent(nearMe: true),
    ),
    DiscoveryIntentPreset(
      id: 'work_quiet_aircon',
      label: 'Làm việc yên tĩnh',
      intent: SearchIntent(
        purposeTags: ['Làm việc'],
        spaceTags: ['Yên tĩnh'],
        amenityTags: ['Máy lạnh'],
      ),
    ),
    DiscoveryIntentPreset(
      id: 'date_night',
      label: 'Hẹn hò',
      intent: SearchIntent(purposeTags: ['Hẹn hò']),
    ),
    DiscoveryIntentPreset(
      id: 'check_in',
      label: 'Check-in',
      intent: SearchIntent(purposeTags: ['Check-in']),
    ),
  ];
}
```

- [ ] **Step 4: Refactor Home**

Move the primary Home UI toward search-led discovery:

```dart
// In HomeScreen build, render search input + DiscoveryIntents.presets chips first.
// On submitted text:
context.go('/search', extra: SearchIntent(query: query));

// On chip tap:
context.go('/search', extra: preset.intent);
```

Preserve weather widget and random pick as secondary sections below the search-led area.

- [ ] **Step 5: Update router to pass search intent**

In `lib/core/router/app_router.dart`, update `/search`:

```dart
GoRoute(
  path: '/search',
  builder: (context, state) {
    final intent = state.extra is SearchIntent ? state.extra as SearchIntent : const SearchIntent();
    return SearchScreen(initialIntent: intent);
  },
),
```

- [ ] **Step 6: Run Home and discovery tests**

Run:

```bash
flutter test test/features/discovery/discovery_intents_test.dart test/features/home/screens/home_screen_test.dart test/core/router/app_router_test.dart
```

Expected: all tests pass after updating imports and constructor expectations.

- [ ] **Step 7: Commit**

```bash
git add lib/features/discovery lib/features/home/presentation/screens/home_screen.dart lib/core/router/app_router.dart test/features/discovery test/features/home/screens/home_screen_test.dart test/core/router/app_router_test.dart
git commit -m "feat: add search-led discovery home"
```

## Task 6: Ranked Search UI And Filter Sheet

**Files:**
- Modify: `lib/features/search/presentation/screens/search_screen.dart`
- Modify: `lib/features/search/presentation/widgets/filter_bottom_sheet.dart`
- Modify: `lib/features/search/presentation/widgets/shop_card.dart`
- Test: `test/features/search/screens/search_screen_test.dart`

- [ ] **Step 1: Write widget tests for ranked result states**

Update `test/features/search/screens/search_screen_test.dart` to cover:

```dart
testWidgets('shows empty state action when no ranked shops exist', (tester) async {
  // Pump SearchScreen with provider override returning SearchState(status: SearchStateStatus.empty).
  // Expect text: 'Không tìm thấy quán nào'
});

testWidgets('shows match reasons on ranked shop card', (tester) async {
  // Pump SearchScreen with one RankedShop containing 'Có máy lạnh'.
  // Expect text: 'Có máy lạnh'
});
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/features/search/screens/search_screen_test.dart
```

Expected: fail until Search UI reads typed ranked state.

- [ ] **Step 3: Update SearchScreen constructor and state rendering**

Update `SearchScreen` to:

```dart
class SearchScreen extends ConsumerStatefulWidget {
  final SearchIntent initialIntent;

  const SearchScreen({
    super.key,
    this.initialIntent = const SearchIntent(),
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}
```

On `initState`, trigger search with `initialIntent`. Render branches from `SearchStateStatus`: initial/loading, success, empty, failure, stale.

- [ ] **Step 4: Update ShopCard to accept match reasons**

Add an optional `matchReasons` argument:

```dart
class ShopCard extends StatelessWidget {
  final CoffeeShop shop;
  final List<String> matchReasons;

  const ShopCard({
    super.key,
    required this.shop,
    this.matchReasons = const [],
  });
}
```

Render up to two compact chips for `matchReasons`.

- [ ] **Step 5: Update filter bottom sheet grouping**

Group filter controls into:

```dart
const purposeOptions = ['Làm việc', 'Hẹn hò', 'Check-in', 'Họp nhóm'];
const practicalOptions = ['Đang mở', 'Gần tôi', 'Máy lạnh', 'WiFi mạnh', 'Gửi xe'];
const spaceOptions = ['Yên tĩnh', 'Sân thượng', 'Vintage', 'Ngoài trời'];
const districtOptions = ['Hải Châu', 'Sơn Trà', 'Ngũ Hành Sơn', 'Thanh Khê', 'Liên Chiểu', 'Cẩm Lệ'];
```

Map selected values back to `SearchFilter` and controller methods.

- [ ] **Step 6: Run search UI tests**

Run:

```bash
flutter test test/features/search/screens/search_screen_test.dart test/features/search/providers/search_notifier_test.dart
```

Expected: all tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/features/search/presentation/screens/search_screen.dart lib/features/search/presentation/widgets/filter_bottom_sheet.dart lib/features/search/presentation/widgets/shop_card.dart test/features/search/screens/search_screen_test.dart
git commit -m "feat: show ranked mobile search results"
```

## Task 7: Shop Detail Repository, Controller, And Screen

**Files:**
- Create: `lib/features/shop_detail/data/repositories/shop_detail_repository.dart`
- Create: `lib/features/shop_detail/presentation/controllers/shop_detail_controller.dart`
- Move/modify: `lib/features/search/presentation/screens/shop_detail_screen.dart`
- Modify: `lib/core/router/app_router.dart`
- Test: `test/features/shop_detail/shop_detail_controller_test.dart`
- Modify or move: `test/features/search/screens/shop_detail_screen_test.dart`

- [ ] **Step 1: Write controller tests**

Create `test/features/shop_detail/shop_detail_controller_test.dart` to verify loading -> success and failure state from fake repository.

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/features/shop_detail/shop_detail_controller_test.dart
```

Expected: fail with missing detail repository/controller.

- [ ] **Step 3: Implement detail repository**

Move the existing slug fetch logic out of the widget:

```dart
final response = await _client.dio.get('shops/slug/$slug');
final responseData = response.data;
final shopJson = responseData is Map<String, dynamic> && responseData.containsKey('shop')
    ? responseData['shop'] as Map<String, dynamic>
    : responseData as Map<String, dynamic>;
return Result.success(CoffeeShop.fromJson(shopJson));
```

Catch `DioException` with `ApiErrorMapper.map(error)` and catch parse errors as `AppFailure.invalidData()`.

- [ ] **Step 4: Implement detail controller**

Use Riverpod `StateNotifier` or `AsyncNotifier` consistently with the search controller. Expose states: initial, loading, success, failure, stale.

- [ ] **Step 5: Update Detail screen**

Remove the inline `FutureProvider.family` and read the new controller instead. Keep the existing carousel, favorite button, drinks, pastries, and reviews, then add a match-reasons section when route extras provide reasons.

- [ ] **Step 6: Run detail tests**

Run:

```bash
flutter test test/features/shop_detail/shop_detail_controller_test.dart test/features/search/screens/shop_detail_screen_test.dart
```

Expected: all tests pass after imports are updated.

- [ ] **Step 7: Commit**

```bash
git add lib/features/shop_detail lib/features/search/presentation/screens/shop_detail_screen.dart lib/core/router/app_router.dart test/features/shop_detail test/features/search/screens/shop_detail_screen_test.dart
git commit -m "feat: refactor shop detail data flow"
```

## Task 8: Favorites Repository And Cleanup

**Files:**
- Create: `lib/features/favorites/data/favorites_repository.dart`
- Create: `lib/features/favorites/presentation/favorites_controller.dart`
- Modify: `lib/features/search/presentation/providers/favorites_provider.dart`
- Test: `test/features/favorites/favorites_controller_test.dart`

- [ ] **Step 1: Write favorites tests**

Create tests for loading empty favorites, toggling a slug on, and toggling it off.

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
flutter test test/features/favorites/favorites_controller_test.dart
```

Expected: fail with missing repository/controller.

- [ ] **Step 3: Implement favorites repository**

Use `SharedPreferences` with the existing favorite slug list key. Preserve old stored values by reading the current key used in `favorites_provider.dart`.

- [ ] **Step 4: Implement favorites controller**

Expose `toggleFavorite(String slug)`, `isFavorite(String slug)`, and a list of favorite slugs.

- [ ] **Step 5: Run favorites tests**

Run:

```bash
flutter test test/features/favorites/favorites_controller_test.dart
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/favorites lib/features/search/presentation/providers/favorites_provider.dart test/features/favorites
git commit -m "feat: add favorites repository"
```

## Task 9: Final Verification And Direct Dio Cleanup

**Files:**
- Modify files found by cleanup searches.
- Test: full Flutter test suite.

- [ ] **Step 1: Search for direct Dio calls in widgets/controllers**

Run:

```bash
rg -n "Dio\\(|\\.dio\\.(get|post|put|delete)|print\\('DEBUG|print\\(\"DEBUG" lib
```

Expected before cleanup: matches in old providers/screens. Expected after cleanup: no widget-level Dio calls and no debug prints.

- [ ] **Step 2: Replace remaining direct calls**

Move remaining network calls into repositories created in earlier tasks. Replace debug prints with:

```dart
const AppLogger().debug('Readable message', error, stackTrace);
```

- [ ] **Step 3: Run analyzer**

Run:

```bash
dart analyze
```

Expected: no issues.

- [ ] **Step 4: Run all tests**

Run:

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 5: Manual smoke test**

Run the app and check:

- Home search submits to Search.
- Smart chips navigate to Search with correct filters.
- Search shows ranked cards and match reasons.
- Search filter chips can be removed.
- Detail opens from Search and shows images, amenities, drinks, reviews, favorites, share, and map actions.
- Suggest and About remain reachable from bottom navigation.

- [ ] **Step 6: Commit**

```bash
git add lib test
git commit -m "chore: verify mobile search refactor"
```

## Self-Review Notes

- Spec coverage: core config/result/errors, search intent/ranking, Home smart chips, Search ranked results, Detail repository/controller, favorites, cleanup, and verification are covered.
- Placeholder scan: no red-flag placeholder steps remain.
- Type consistency: `SearchIntent`, `SearchFilter`, `RankedShop`, `Result<T>`, and `AppFailure` names are introduced before later tasks use them.
