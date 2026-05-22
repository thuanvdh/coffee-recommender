const _unset = Object();

class SearchFilter {
  SearchFilter({
    this.district,
    this.purpose,
    this.amenity,
    this.space,
    this.openNow,
  });

  final String? district;
  final String? purpose;
  final String? amenity;
  final String? space;
  final bool? openNow;

  SearchFilter copyWith({
    Object? district = _unset,
    Object? purpose = _unset,
    Object? amenity = _unset,
    Object? space = _unset,
    Object? openNow = _unset,
  }) {
    return SearchFilter(
      district: district == _unset ? this.district : district as String?,
      purpose: purpose == _unset ? this.purpose : purpose as String?,
      amenity: amenity == _unset ? this.amenity : amenity as String?,
      space: space == _unset ? this.space : space as String?,
      openNow: openNow == _unset ? this.openNow : openNow as bool?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SearchFilter &&
            other.district == district &&
            other.purpose == purpose &&
            other.amenity == amenity &&
            other.space == space &&
            other.openNow == openNow;
  }

  @override
  int get hashCode => Object.hash(
        district,
        purpose,
        amenity,
        space,
        openNow,
      );
}
