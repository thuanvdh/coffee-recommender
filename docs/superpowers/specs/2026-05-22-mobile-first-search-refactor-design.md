# Mobile-first Search Refactor Design

## Context

The Flutter app currently has the main coffee discovery screens in place, but widgets still hold too much network, parsing, and decision logic. Search and detail flows call Dio-adjacent providers directly, error states are inconsistent, debug logging is still present, and the mobile experience mostly mirrors a list-based web flow.

This design defines a focused refactor for the app's most important user journey: helping someone quickly find a suitable coffee shop in Da Nang from a phone.

## Goals

- Make the app mobile-first around the journey: Home -> quick search intent -> ranked Search results -> Detail -> action.
- Refactor the technical foundation for this vertical slice using clear feature boundaries, typed data flow, and testable controllers.
- Keep the backend API unchanged for this phase unless a small compatibility fix is required.
- Preserve current core capabilities: shop search, filters, detail, images, reviews, suggestions integration points, and favorites storage.
- Improve resilience with typed errors, retry states, and lightweight cache fallback.

## Non-goals

- Full parity with the React web app.
- Admin features in Flutter.
- Account login or cloud-synced favorites.
- Large backend schema changes.
- A complete redesign of every secondary screen in the app.

## Recommended Approach

Use a mobile-first vertical slice rather than a big-bang rewrite. The first implementation phase should rebuild the discovery/search/detail path while keeping secondary screens compatible. This gives the architecture a real product flow to prove itself against and limits regression risk.

## User Experience

### Home: Search-led Discovery

Home becomes the starting point for "find a shop that fits now" rather than a long intro page.

It should include:

- A primary search bar for shop name, area, amenity, purpose, or mood terms.
- Smart chips for common intents such as `Gan toi`, `Dang mo`, `Lam viec`, `Yen tinh`, `May lanh`, `Hen ho`, `Check-in`, and `Co banh`.
- Contextual suggestions from weather, current time, location availability, and recent intents.
- A secondary random pick action that stays available but does not dominate the page.

Tapping a chip or submitting the search bar creates a `SearchIntent` and navigates to Search.

### Search: Ranked Results And Advanced Filters

Search receives a `SearchIntent`, fetches candidate shops, applies filter and ranking rules, and presents results by relevance.

The screen should include:

- Search input with the current query.
- Active filter chips that can be removed individually.
- A filter bottom sheet grouped by purpose, practical conditions, space/drink preference, and district.
- Result cards that show the strongest match signals.
- Empty, loading, error, and stale-cache states with clear next actions.

### Detail: Decision Support

Detail helps the user decide whether to go.

It should include:

- Image carousel with graceful fallback.
- Open status, district, rating or review summary, address, and distance when available.
- A "why this matches" section when the user arrived from a ranked search.
- Amenities, spaces, drinks, pastries, and review sections.
- A persistent action area for directions, favorite, share, and external map/call actions when data exists.

Missing optional data should degrade gracefully.

## Architecture

Use feature-first clean architecture for the vertical slice.

```text
lib/
  core/
    config/
    network/
    result/
    storage/
    logging/
  features/
    discovery/
      domain/
      presentation/
    search/
      data/
      domain/
      presentation/
    shop_detail/
      data/
      domain/
      presentation/
    favorites/
      data/
      domain/
      presentation/
```

### Core

- `core/config`: environment-aware API base URL and feature flags.
- `core/network`: Dio client, interceptors, timeout configuration, request helpers, and response normalization.
- `core/result`: a sealed `Result<T>` type with success and failure cases.
- `core/storage`: shared preferences wrappers for favorites, recent intents, and cache metadata.
- `core/logging`: small logging wrapper that can be disabled in production.

### Feature Boundaries

- `discovery`: Home screen, smart chips, recent intent loading, weather/location availability, and creation of `SearchIntent`.
- `search`: query/filter domain objects, repository, ranking logic, controller, and search UI.
- `shop_detail`: detail repository, controller, detail UI, and review submission through the existing backend endpoint.
- `favorites`: local favorite store and controller shared by Search and Detail.

Widgets should not call Dio directly. Widgets render state and send user events to controllers.

## Data Model

Introduce explicit mapping between API data and app domain data.

- `CoffeeShopDto`: mirrors backend JSON.
- `CoffeeShop`: domain model used by UI and ranking.
- `ShopDetail`: richer domain model for detail-only fields such as images, drinks, pastries, reviews, and full description.
- `SearchIntent`: query, purpose tags, amenity tags, space tags, district, `nearMe`, `openNow`, optional lat/lon, and mood tags.
- `SearchFilter`: advanced filter state.
- `RankedShop`: `CoffeeShop`, score, and human-readable match reasons.
- `AppFailure`: typed error such as timeout, network unavailable, server error, unauthorized, invalid data, and unknown.

The DTO-to-domain mapper should absorb backend inconsistencies and provide safe defaults for optional lists and images.

## Data Flow

```text
UI event
  -> Riverpod controller
  -> use case or service
  -> repository
  -> API client and cache layer
  -> Result<T>
  -> controller state
  -> UI render
```

Home creates a `SearchIntent`. Search converts it to API query parameters, fetches shops, maps DTOs to domain shops, applies local ranking, and stores the last successful result in memory cache. Detail fetches by slug through its own repository and can reuse cached shops as a fast initial render.

## Error, Loading, And Cache Behavior

Each controller state should represent:

- Initial.
- Loading with optional previous data.
- Success.
- Empty.
- Failure without data.
- Failure with stale cached data.

Network failures should show retry actions. Invalid data should show a user-safe message and log technical details through the logging wrapper. If cached data exists, the UI should show it with a subtle stale indicator.

## Testing Strategy

Add or update tests for:

- DTO-to-domain mapping with missing optional fields.
- SearchIntent to API query parameter conversion.
- Ranking score and match reason generation.
- Repository success, server failure, timeout, and invalid data handling.
- Controller loading, success, empty, error, and stale-cache transitions.
- Home smart chip interactions.
- Search loading/error/empty/success rendering.
- Detail render with complete and partial data.

Existing tests should be updated to target the new boundaries instead of direct widget-network coupling.

## Implementation Phases

1. Create core config, result, logging, storage, and network foundations.
2. Introduce search/detail DTOs, domain models, and mappers.
3. Build search repository and ranking service.
4. Refactor Home into search-led discovery with smart chips and `SearchIntent`.
5. Refactor Search around controller state, grouped filters, ranked results, and robust UI states.
6. Refactor Detail into its own repository/controller and decision-support layout.
7. Reconnect favorites and review submission through feature controllers.
8. Update tests and remove direct Dio calls and debug prints from widgets/controllers.

## Acceptance Criteria

- Home can create meaningful search intents from text search and smart chips.
- Search results are ranked and show match reasons when available.
- Advanced filters are grouped and removable through active chips.
- Detail can render from slug, handle partial data, and expose primary actions.
- Widgets do not call Dio directly.
- API errors are typed and converted into consistent UI states.
- The app has test coverage for mapping, query building, ranking, repositories, controllers, and key widgets.
- Existing app navigation remains usable for Home, Search, Detail, Suggest, and About.
