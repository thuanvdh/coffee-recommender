class SearchIntent {
  const SearchIntent({
    this.query,
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

  final String? query;
  final List<String> purposeTags;
  final List<String> amenityTags;
  final List<String> spaceTags;
  final String? district;
  final bool nearMe;
  final bool openNow;
  final double? latitude;
  final double? longitude;
  final List<String> moodTags;
}
