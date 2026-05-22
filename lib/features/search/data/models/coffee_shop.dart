import 'package:freezed_annotation/freezed_annotation.dart';

part 'coffee_shop.freezed.dart';
part 'coffee_shop.g.dart';

@freezed
class CoffeeShop with _$CoffeeShop {
  const factory CoffeeShop({
    required int id,
    required String name,
    required String slug,
    String? address,
    String? district,
    required String status,
    @Default([]) List<String> purposes,
    @Default([]) List<String> spaces,
    @Default([]) List<String> amenities,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _CoffeeShop;

  factory CoffeeShop.fromJson(Map<String, dynamic> json) => _$CoffeeShopFromJson(json);
}
