import 'package:freezed_annotation/freezed_annotation.dart';

part 'coffee_shop.freezed.dart';
part 'coffee_shop.g.dart';

@freezed
class Review with _$Review {
  const factory Review({
    required int id,
    @JsonKey(name: 'user_name') required String userName,
    required int rating,
    String? comment,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}

@freezed
class Drink with _$Drink {
  const factory Drink({
    required int id,
    required String name,
    String? price,
    @Default('drink') String category,
    @JsonKey(name: 'is_signature') @Default(false) bool isSignature,
    @JsonKey(name: 'is_trending') @Default(false) bool isTrending,
  }) = _Drink;

  factory Drink.fromJson(Map<String, dynamic> json) => _$DrinkFromJson(json);
}

@freezed
class ShopImage with _$ShopImage {
  const factory ShopImage({
    required int id,
    required String url,
    @JsonKey(name: 'alt_text') String? altText,
  }) = _ShopImage;

  factory ShopImage.fromJson(Map<String, dynamic> json) => _$ShopImageFromJson(json);
}

@freezed
class CoffeeShop with _$CoffeeShop {
  const factory CoffeeShop({
    required int id,
    required String name,
    required String slug,
    String? address,
    String? district,
    String? phone,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? description,
    @JsonKey(name: 'opening_hours') String? openingHours,
    @JsonKey(name: 'price_range') String? priceRange,
    required String status,
    double? latitude,
    double? longitude,
    @Default([]) List<String> purposes,
    @Default([]) List<String> spaces,
    @Default([]) List<String> amenities,
    @Default([]) List<Drink> drinks,
    @Default([]) List<ShopImage> images,
    @Default([]) List<Review> reviews,
    @JsonKey(name: 'distance_km') double? distanceKm,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _CoffeeShop;

  factory CoffeeShop.fromJson(Map<String, dynamic> json) => _$CoffeeShopFromJson(json);
}
