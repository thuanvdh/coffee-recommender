import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';

class SearchQueryBuilder {
  Map<String, Object> build({
    required SearchIntent intent,
    SearchFilter? filter,
  }) {
    final effectiveFilter = filter ?? SearchFilter();
    final params = <String, Object>{};

    _addString(params, 'search', intent.query);
    _addString(
      params,
      'purpose',
      effectiveFilter.purpose ?? _first(intent.purposeTags),
    );
    _addString(
      params,
      'amenity',
      effectiveFilter.amenity ?? _first(intent.amenityTags),
    );
    _addString(
      params,
      'space',
      effectiveFilter.space ?? _first(intent.spaceTags),
    );
    _addString(params, 'district', effectiveFilter.district ?? intent.district);

    final openNow = effectiveFilter.openNow ?? intent.openNow;
    if (openNow) {
      params['open_now'] = true;
    }

    if (intent.nearMe && intent.latitude != null && intent.longitude != null) {
      params['lat'] = intent.latitude!;
      params['lon'] = intent.longitude!;
    }

    return params;
  }

  static String? _first(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  static void _addString(
    Map<String, Object> params,
    String key,
    String? value,
  ) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      params[key] = trimmed;
    }
  }
}
