# Mobile-first Search Refactor Implementation Plan

Design spec: `docs/superpowers/specs/2026-05-22-mobile-first-search-refactor-design.md`

## Goal

Refactor the Flutter app around the mobile-first flow: Home search intent -> ranked Search results -> Detail decision support. Keep the backend API unchanged and improve architecture, typed errors, cache behavior, and tests.

## Guardrails

- Do not introduce admin or account features in this phase.
- Keep existing navigation destinations usable: Home, Search, Detail, Suggest, About.
- Do not let widgets call Dio directly.
- Prefer small, testable feature modules over broad shared abstractions.
- Keep backend compatibility unless a minimal API fix is unavoidable.

## Phase 1: Core Foundation

### Task 1.1: Add app config

Files:

- Create `lib/core/config/app_config.dart`
- Update `lib/core/network/dio_client.dart`
- Add tests in `test/core/config/app_config_test.dart`

Steps:

1. Add an `AppConfig` object with API base URL and environment name.
2. Read the base URL from `String.fromEnvironment`, with a development default.
3. Inject config into `DioClient`.
4. Test default and overridden base URL behavior.

### Task 1.2: Add typed result and failures

Files:

- Create `lib/core/result/result.dart`
- Create `lib/core/result/app_failure.dart`
- Add tests in `test/core/result/result_test.dart`

Steps:

1. Define a sealed `Result<T>` with success and failure cases.
2. Define `AppFailure` variants for timeout, network, server, unauthorized, invalid data, and unknown.
3. Add helper methods for mapping and folding results.
4. Test success/failure handling and user-safe messages.

### Task 1.3: Normalize network errors

Files:

- Update `lib/core/network/dio_client.dart`
- Add `lib/core/network/api_error_mapper.dart`
- Update or create `test/core/network/dio_client_test.dart`

Steps:

1. Centralize Dio timeout and response configuration.
2. Map `DioException` to `AppFailure`.
3. Remove direct debug `print` expectations from network code.
4. Test timeout, no connection, server error, unauthorized, and invalid response mapping.

## Phase 2: Search Domain And Data Layer

### Task 2.1: Introduce search domain models

Files:

- Create `lib/features/search/domain/models/search_intent.dart`
- Create `lib/features/search/domain/models/search_filter.dart`
- Create `lib/features/search/domain/models/ranked_shop.dart`
- Update tests under `test/features/search/domain/`

Steps:

1. Model `SearchIntent` with query, purpose tags, amenity tags, space tags, district, near-me, open-now, lat/lon, and mood tags.
2. Model `SearchFilter` for advanced filter state.
3. Model `RankedShop` with shop, score, and match reasons.
4. Test equality, defaults, and copy/update behavior.

### Task 2.2: Split DTO and domain mapping

Files:

- Add `lib/features/search/data/dtos/coffee_shop_dto.dart`
- Keep or adapt `lib/features/search/data/models/coffee_shop.dart` as the domain model
- Add `lib/features/search/data/mappers/coffee_shop_mapper.dart`
- Update `test/features/search/models/coffee_shop_test.dart`

Steps:

1. Make DTO mirror backend JSON safely.
2. Map DTO to domain with safe defaults for optional lists, images, drinks, and reviews.
3. Keep UI-facing domain fields stable for existing widgets during transition.
4. Test complete, partial, and malformed-but-recoverable payloads.

### Task 2.3: Build search query and ranking services

Files:

- Create `lib/features/search/domain/services/search_query_builder.dart`
- Create `lib/features/search/domain/services/shop_ranking_service.dart`
- Add tests under `test/features/search/domain/services/`

Steps:

1. Convert `SearchIntent` and `SearchFilter` into backend query parameters.
2. Implement deterministic local ranking for purpose, amenities, spaces, district, open-now, and near-me signals.
3. Generate short match reasons for result cards.
4. Test query params, scores, sort order, and match reasons.

### Task 2.4: Add search repository

Files:

- Create `lib/features/search/data/repositories/search_repository.dart`
- Add tests in `test/features/search/data/search_repository_test.dart`

Steps:

1. Move shop list fetching out of `SearchNotifier`.
2. Return `Result<List<CoffeeShop>>`.
3. Support last-successful in-memory cache for stale fallback.
4. Test success, empty, failure without cache, and failure with cache.

## Phase 3: Controllers And UI State

### Task 3.1: Refactor SearchController state

Files:

- Replace or refactor `lib/features/search/presentation/providers/search_notifier.dart`
- Add `lib/features/search/presentation/state/search_state.dart`
- Update `test/features/search/providers/search_notifier_test.dart`

Steps:

1. Represent initial, loading, success, empty, failure, and stale-cache states.
2. Accept `SearchIntent` as the primary input.
3. Use repository, query builder, and ranking service.
4. Keep compatibility methods for existing filter interactions until UI migration finishes.

### Task 3.2: Add DiscoveryController

Files:

- Create `lib/features/discovery/domain/discovery_intents.dart`
- Create `lib/features/discovery/presentation/controllers/discovery_controller.dart`
- Add tests under `test/features/discovery/`

Steps:

1. Define smart chip presets that produce `SearchIntent`.
2. Track recent intents in local storage.
3. Expose weather/location availability without blocking the Home UI.
4. Test chip-to-intent mapping and recent intent persistence.

### Task 3.3: Refactor ShopDetailController

Files:

- Create `lib/features/shop_detail/data/repositories/shop_detail_repository.dart`
- Create `lib/features/shop_detail/presentation/controllers/shop_detail_controller.dart`
- Move detail state out of `shop_detail_screen.dart`
- Add tests under `test/features/shop_detail/`

Steps:

1. Move slug detail fetching out of the widget.
2. Reuse cached shop data for fast initial display when available.
3. Return typed detail states for loading, success, partial/stale, and failure.
4. Keep review submission routed through controller/repository.

## Phase 4: Mobile-first Screens

### Task 4.1: Rebuild Home as search-led discovery

Files:

- Update `lib/features/home/presentation/screens/home_screen.dart`
- Add focused widgets under `lib/features/discovery/presentation/widgets/`
- Update `test/features/home/screens/home_screen_test.dart`

Steps:

1. Put search input and smart chips at the top of Home.
2. Convert text/chip actions into `SearchIntent`.
3. Navigate to Search with serialized intent data.
4. Keep random pick as a secondary action.
5. Test primary search, chip tap, and navigation intent.

### Task 4.2: Rebuild Search around ranked results

Files:

- Update `lib/features/search/presentation/screens/search_screen.dart`
- Update `lib/features/search/presentation/widgets/filter_bottom_sheet.dart`
- Update `lib/features/search/presentation/widgets/shop_card.dart`
- Update `test/features/search/screens/search_screen_test.dart`

Steps:

1. Hydrate Search from route query or navigation extra.
2. Show active filters as removable chips.
3. Group filters by purpose, practical conditions, space/drink preference, and district.
4. Render ranked shop cards with match reasons.
5. Add clear loading, empty, error, and stale-cache states.

### Task 4.3: Rebuild Detail for decision support

Files:

- Update or move `lib/features/search/presentation/screens/shop_detail_screen.dart` into `features/shop_detail`
- Add detail widgets under `lib/features/shop_detail/presentation/widgets/`
- Update `lib/core/router/app_router.dart`
- Update `test/features/search/screens/shop_detail_screen_test.dart` or move tests to `shop_detail`

Steps:

1. Render detail from `ShopDetailController`.
2. Add decision sections: match reasons, amenities, drinks/pastries, reviews.
3. Add action area for directions, favorite, share, and external map/call when available.
4. Handle partial data without layout gaps or crashes.

## Phase 5: Favorites, Cleanup, And Verification

### Task 5.1: Reconnect favorites through a feature controller

Files:

- Refactor `lib/features/search/presentation/providers/favorites_provider.dart`
- Add or update tests for favorites storage

Steps:

1. Move persistence behind a favorites repository.
2. Expose a controller shared by Search and Detail.
3. Preserve current favorite slugs during migration.
4. Test toggle, load, and persistence behavior.

### Task 5.2: Remove direct Dio calls and debug prints

Files:

- Search all `lib/` files for direct `Dio`, `.dio.get`, `.dio.post`, and `print('DEBUG`

Steps:

1. Replace direct calls with repositories.
2. Replace debug prints with logging wrapper.
3. Confirm widgets do not import `dio`.

### Task 5.3: Run verification

Commands:

```bash
flutter test
dart analyze
```

Manual checks:

- Home text search navigates to Search.
- Each smart chip produces expected filters/results.
- Search can load, retry, clear filters, and open Detail.
- Detail handles image fallback, partial data, favorite, share, and directions.
- Suggest and About remain reachable.

## Done Criteria

- The vertical slice follows the design spec.
- Widgets no longer call Dio directly.
- Search and Detail use repositories and typed `Result`.
- Home produces `SearchIntent` from search and smart chips.
- Search results are ranked and show match reasons.
- Error, loading, empty, and stale-cache states are covered.
- Tests and analyzer pass.

