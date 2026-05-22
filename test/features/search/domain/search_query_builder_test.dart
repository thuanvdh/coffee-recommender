import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_recommender/features/search/domain/models/search_filter.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';
import 'package:coffee_recommender/features/search/domain/services/search_query_builder.dart';

void main() {
  test('builds backend query parameters from intent and filter', () {
    final intent = SearchIntent(
      query: 'espresso',
      amenityTags: ['Máy lạnh'],
      spaceTags: ['Yên tĩnh'],
      nearMe: true,
      latitude: 16.0544,
      longitude: 108.2022,
    );
    final filter = SearchFilter(district: 'Hải Châu', openNow: true);

    final params = SearchQueryBuilder().build(intent: intent, filter: filter);

    expect(params['search'], 'espresso');
    expect(params['amenity'], 'Máy lạnh');
    expect(params['space'], 'Yên tĩnh');
    expect(params['district'], 'Hải Châu');
    expect(params['open_now'], isTrue);
    expect(params['lat'], 16.0544);
    expect(params['lon'], 108.2022);
  });

  test('emits open_now from intent when no filter override is provided', () {
    final intent = SearchIntent(openNow: true);

    final params = SearchQueryBuilder().build(intent: intent);

    expect(params, {'open_now': true});
  });

  test('filter values take precedence over intent tags', () {
    final intent = SearchIntent(
      purposeTags: ['Làm việc'],
      amenityTags: ['Máy lạnh'],
      spaceTags: ['Yên tĩnh'],
      district: 'Sơn Trà',
    );
    final filter = SearchFilter(
      purpose: 'Hẹn hò',
      amenity: 'Ngoài trời',
      space: 'Rộng rãi',
      district: 'Hải Châu',
    );

    final params = SearchQueryBuilder().build(intent: intent, filter: filter);

    expect(params['purpose'], 'Hẹn hò');
    expect(params['amenity'], 'Ngoài trời');
    expect(params['space'], 'Rộng rãi');
    expect(params['district'], 'Hải Châu');
  });

  test('ignores trimmed empty query and tags', () {
    final intent = SearchIntent(
      query: '   ',
      purposeTags: [' ', '\t'],
      amenityTags: [' ', 'Máy lạnh'],
      spaceTags: ['\n'],
    );

    final params = SearchQueryBuilder().build(intent: intent);

    expect(params, {'amenity': 'Máy lạnh'});
  });

  test('nearMe does not emit coordinates when coords are missing', () {
    final params = SearchQueryBuilder().build(
      intent: SearchIntent(nearMe: true, latitude: 16.0544),
    );

    expect(params.containsKey('lat'), isFalse);
    expect(params.containsKey('lon'), isFalse);
  });

  test('search intent defaults query and protects list values', () {
    final tags = ['Làm việc'];
    final intent = SearchIntent(purposeTags: tags);

    tags.add('Hẹn hò');

    expect(intent.query, '');
    expect(intent.purposeTags, ['Làm việc']);
    expect(() => intent.purposeTags.add('Check-in'), throwsUnsupportedError);
    expect(intent, SearchIntent(purposeTags: ['Làm việc']));
    expect(
      intent.copyWith(district: 'Hải Châu').copyWith(district: null).district,
      isNull,
    );
  });

  test('search filter supports value equality and nullable copyWith', () {
    final filter = SearchFilter(district: 'Hải Châu', openNow: true);

    expect(filter, SearchFilter(district: 'Hải Châu', openNow: true));
    expect(filter.copyWith(openNow: false).openNow, isFalse);
    expect(filter.copyWith(district: null).district, isNull);
  });
}
