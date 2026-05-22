import 'package:flutter/foundation.dart';

const _unset = Object();

class SearchIntent {
  SearchIntent({
    this.query = '',
    List<String> purposeTags = const [],
    List<String> amenityTags = const [],
    List<String> spaceTags = const [],
    this.district,
    this.nearMe = false,
    this.openNow = false,
    this.latitude,
    this.longitude,
    List<String> moodTags = const [],
  })  : purposeTags = List.unmodifiable(purposeTags),
        amenityTags = List.unmodifiable(amenityTags),
        spaceTags = List.unmodifiable(spaceTags),
        moodTags = List.unmodifiable(moodTags);

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

  SearchIntent copyWith({
    String? query,
    List<String>? purposeTags,
    List<String>? amenityTags,
    List<String>? spaceTags,
    Object? district = _unset,
    bool? nearMe,
    bool? openNow,
    Object? latitude = _unset,
    Object? longitude = _unset,
    List<String>? moodTags,
  }) {
    return SearchIntent(
      query: query ?? this.query,
      purposeTags: purposeTags ?? this.purposeTags,
      amenityTags: amenityTags ?? this.amenityTags,
      spaceTags: spaceTags ?? this.spaceTags,
      district: district == _unset ? this.district : district as String?,
      nearMe: nearMe ?? this.nearMe,
      openNow: openNow ?? this.openNow,
      latitude: latitude == _unset ? this.latitude : latitude as double?,
      longitude: longitude == _unset ? this.longitude : longitude as double?,
      moodTags: moodTags ?? this.moodTags,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SearchIntent &&
            other.query == query &&
            listEquals(other.purposeTags, purposeTags) &&
            listEquals(other.amenityTags, amenityTags) &&
            listEquals(other.spaceTags, spaceTags) &&
            other.district == district &&
            other.nearMe == nearMe &&
            other.openNow == openNow &&
            other.latitude == latitude &&
            other.longitude == longitude &&
            listEquals(other.moodTags, moodTags);
  }

  @override
  int get hashCode => Object.hash(
        query,
        Object.hashAll(purposeTags),
        Object.hashAll(amenityTags),
        Object.hashAll(spaceTags),
        district,
        nearMe,
        openNow,
        latitude,
        longitude,
        Object.hashAll(moodTags),
      );
}
