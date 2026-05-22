class SearchFilter {
  const SearchFilter({
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
}
