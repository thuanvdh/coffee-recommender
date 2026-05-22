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
