// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coffee_shop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Review _$ReviewFromJson(Map<String, dynamic> json) {
  return _Review.fromJson(json);
}

/// @nodoc
mixin _$Review {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_name')
  String get userName => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Review to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewCopyWith<Review> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewCopyWith<$Res> {
  factory $ReviewCopyWith(Review value, $Res Function(Review) then) =
      _$ReviewCopyWithImpl<$Res, Review>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_name') String userName,
      int rating,
      String? comment,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class _$ReviewCopyWithImpl<$Res, $Val extends Review>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userName = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewImplCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$$ReviewImplCopyWith(
          _$ReviewImpl value, $Res Function(_$ReviewImpl) then) =
      __$$ReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_name') String userName,
      int rating,
      String? comment,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class __$$ReviewImplCopyWithImpl<$Res>
    extends _$ReviewCopyWithImpl<$Res, _$ReviewImpl>
    implements _$$ReviewImplCopyWith<$Res> {
  __$$ReviewImplCopyWithImpl(
      _$ReviewImpl _value, $Res Function(_$ReviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userName = null,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$ReviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewImpl implements _Review {
  const _$ReviewImpl(
      {required this.id,
      @JsonKey(name: 'user_name') required this.userName,
      required this.rating,
      this.comment,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$ReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'user_name')
  final String userName;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'Review(id: $id, userName: $userName, rating: $rating, comment: $comment, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userName, rating, comment, createdAt);

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      __$$ReviewImplCopyWithImpl<_$ReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewImplToJson(
      this,
    );
  }
}

abstract class _Review implements Review {
  const factory _Review(
          {required final int id,
          @JsonKey(name: 'user_name') required final String userName,
          required final int rating,
          final String? comment,
          @JsonKey(name: 'created_at') required final String createdAt}) =
      _$ReviewImpl;

  factory _Review.fromJson(Map<String, dynamic> json) = _$ReviewImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'user_name')
  String get userName;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of Review
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewImplCopyWith<_$ReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Drink _$DrinkFromJson(Map<String, dynamic> json) {
  return _Drink.fromJson(json);
}

/// @nodoc
mixin _$Drink {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get price => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_signature')
  bool get isSignature => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_trending')
  bool get isTrending => throw _privateConstructorUsedError;

  /// Serializes this Drink to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Drink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DrinkCopyWith<Drink> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DrinkCopyWith<$Res> {
  factory $DrinkCopyWith(Drink value, $Res Function(Drink) then) =
      _$DrinkCopyWithImpl<$Res, Drink>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? price,
      String category,
      @JsonKey(name: 'is_signature') bool isSignature,
      @JsonKey(name: 'is_trending') bool isTrending});
}

/// @nodoc
class _$DrinkCopyWithImpl<$Res, $Val extends Drink>
    implements $DrinkCopyWith<$Res> {
  _$DrinkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Drink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = freezed,
    Object? category = null,
    Object? isSignature = null,
    Object? isTrending = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      isSignature: null == isSignature
          ? _value.isSignature
          : isSignature // ignore: cast_nullable_to_non_nullable
              as bool,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DrinkImplCopyWith<$Res> implements $DrinkCopyWith<$Res> {
  factory _$$DrinkImplCopyWith(
          _$DrinkImpl value, $Res Function(_$DrinkImpl) then) =
      __$$DrinkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? price,
      String category,
      @JsonKey(name: 'is_signature') bool isSignature,
      @JsonKey(name: 'is_trending') bool isTrending});
}

/// @nodoc
class __$$DrinkImplCopyWithImpl<$Res>
    extends _$DrinkCopyWithImpl<$Res, _$DrinkImpl>
    implements _$$DrinkImplCopyWith<$Res> {
  __$$DrinkImplCopyWithImpl(
      _$DrinkImpl _value, $Res Function(_$DrinkImpl) _then)
      : super(_value, _then);

  /// Create a copy of Drink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = freezed,
    Object? category = null,
    Object? isSignature = null,
    Object? isTrending = null,
  }) {
    return _then(_$DrinkImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      isSignature: null == isSignature
          ? _value.isSignature
          : isSignature // ignore: cast_nullable_to_non_nullable
              as bool,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DrinkImpl implements _Drink {
  const _$DrinkImpl(
      {required this.id,
      required this.name,
      this.price,
      this.category = 'drink',
      @JsonKey(name: 'is_signature') this.isSignature = false,
      @JsonKey(name: 'is_trending') this.isTrending = false});

  factory _$DrinkImpl.fromJson(Map<String, dynamic> json) =>
      _$$DrinkImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? price;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey(name: 'is_signature')
  final bool isSignature;
  @override
  @JsonKey(name: 'is_trending')
  final bool isTrending;

  @override
  String toString() {
    return 'Drink(id: $id, name: $name, price: $price, category: $category, isSignature: $isSignature, isTrending: $isTrending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DrinkImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isSignature, isSignature) ||
                other.isSignature == isSignature) &&
            (identical(other.isTrending, isTrending) ||
                other.isTrending == isTrending));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, price, category, isSignature, isTrending);

  /// Create a copy of Drink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DrinkImplCopyWith<_$DrinkImpl> get copyWith =>
      __$$DrinkImplCopyWithImpl<_$DrinkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DrinkImplToJson(
      this,
    );
  }
}

abstract class _Drink implements Drink {
  const factory _Drink(
      {required final int id,
      required final String name,
      final String? price,
      final String category,
      @JsonKey(name: 'is_signature') final bool isSignature,
      @JsonKey(name: 'is_trending') final bool isTrending}) = _$DrinkImpl;

  factory _Drink.fromJson(Map<String, dynamic> json) = _$DrinkImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get price;
  @override
  String get category;
  @override
  @JsonKey(name: 'is_signature')
  bool get isSignature;
  @override
  @JsonKey(name: 'is_trending')
  bool get isTrending;

  /// Create a copy of Drink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DrinkImplCopyWith<_$DrinkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopImage _$ShopImageFromJson(Map<String, dynamic> json) {
  return _ShopImage.fromJson(json);
}

/// @nodoc
mixin _$ShopImage {
  int get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'alt_text')
  String? get altText => throw _privateConstructorUsedError;

  /// Serializes this ShopImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopImageCopyWith<ShopImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopImageCopyWith<$Res> {
  factory $ShopImageCopyWith(ShopImage value, $Res Function(ShopImage) then) =
      _$ShopImageCopyWithImpl<$Res, ShopImage>;
  @useResult
  $Res call({int id, String url, @JsonKey(name: 'alt_text') String? altText});
}

/// @nodoc
class _$ShopImageCopyWithImpl<$Res, $Val extends ShopImage>
    implements $ShopImageCopyWith<$Res> {
  _$ShopImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? altText = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      altText: freezed == altText
          ? _value.altText
          : altText // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShopImageImplCopyWith<$Res>
    implements $ShopImageCopyWith<$Res> {
  factory _$$ShopImageImplCopyWith(
          _$ShopImageImpl value, $Res Function(_$ShopImageImpl) then) =
      __$$ShopImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String url, @JsonKey(name: 'alt_text') String? altText});
}

/// @nodoc
class __$$ShopImageImplCopyWithImpl<$Res>
    extends _$ShopImageCopyWithImpl<$Res, _$ShopImageImpl>
    implements _$$ShopImageImplCopyWith<$Res> {
  __$$ShopImageImplCopyWithImpl(
      _$ShopImageImpl _value, $Res Function(_$ShopImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShopImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? altText = freezed,
  }) {
    return _then(_$ShopImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      altText: freezed == altText
          ? _value.altText
          : altText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopImageImpl implements _ShopImage {
  const _$ShopImageImpl(
      {required this.id,
      required this.url,
      @JsonKey(name: 'alt_text') this.altText});

  factory _$ShopImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopImageImplFromJson(json);

  @override
  final int id;
  @override
  final String url;
  @override
  @JsonKey(name: 'alt_text')
  final String? altText;

  @override
  String toString() {
    return 'ShopImage(id: $id, url: $url, altText: $altText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.altText, altText) || other.altText == altText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, altText);

  /// Create a copy of ShopImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopImageImplCopyWith<_$ShopImageImpl> get copyWith =>
      __$$ShopImageImplCopyWithImpl<_$ShopImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopImageImplToJson(
      this,
    );
  }
}

abstract class _ShopImage implements ShopImage {
  const factory _ShopImage(
      {required final int id,
      required final String url,
      @JsonKey(name: 'alt_text') final String? altText}) = _$ShopImageImpl;

  factory _ShopImage.fromJson(Map<String, dynamic> json) =
      _$ShopImageImpl.fromJson;

  @override
  int get id;
  @override
  String get url;
  @override
  @JsonKey(name: 'alt_text')
  String? get altText;

  /// Create a copy of ShopImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopImageImplCopyWith<_$ShopImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoffeeShop _$CoffeeShopFromJson(Map<String, dynamic> json) {
  return _CoffeeShop.fromJson(json);
}

/// @nodoc
mixin _$CoffeeShop {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'opening_hours')
  String? get openingHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_range')
  String? get priceRange => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  List<String> get purposes => throw _privateConstructorUsedError;
  List<String> get spaces => throw _privateConstructorUsedError;
  List<String> get amenities => throw _privateConstructorUsedError;
  List<Drink> get drinks => throw _privateConstructorUsedError;
  List<ShopImage> get images => throw _privateConstructorUsedError;
  List<Review> get reviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'distance_km')
  double? get distanceKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CoffeeShop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoffeeShop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoffeeShopCopyWith<CoffeeShop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoffeeShopCopyWith<$Res> {
  factory $CoffeeShopCopyWith(
          CoffeeShop value, $Res Function(CoffeeShop) then) =
      _$CoffeeShopCopyWithImpl<$Res, CoffeeShop>;
  @useResult
  $Res call(
      {int id,
      String name,
      String slug,
      String? address,
      String? district,
      String? phone,
      @JsonKey(name: 'image_url') String? imageUrl,
      String? description,
      @JsonKey(name: 'opening_hours') String? openingHours,
      @JsonKey(name: 'price_range') String? priceRange,
      String status,
      double? latitude,
      double? longitude,
      List<String> purposes,
      List<String> spaces,
      List<String> amenities,
      List<Drink> drinks,
      List<ShopImage> images,
      List<Review> reviews,
      @JsonKey(name: 'distance_km') double? distanceKm,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class _$CoffeeShopCopyWithImpl<$Res, $Val extends CoffeeShop>
    implements $CoffeeShopCopyWith<$Res> {
  _$CoffeeShopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoffeeShop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? address = freezed,
    Object? district = freezed,
    Object? phone = freezed,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? openingHours = freezed,
    Object? priceRange = freezed,
    Object? status = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? purposes = null,
    Object? spaces = null,
    Object? amenities = null,
    Object? drinks = null,
    Object? images = null,
    Object? reviews = null,
    Object? distanceKm = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      openingHours: freezed == openingHours
          ? _value.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      purposes: null == purposes
          ? _value.purposes
          : purposes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      spaces: null == spaces
          ? _value.spaces
          : spaces // ignore: cast_nullable_to_non_nullable
              as List<String>,
      amenities: null == amenities
          ? _value.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      drinks: null == drinks
          ? _value.drinks
          : drinks // ignore: cast_nullable_to_non_nullable
              as List<Drink>,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ShopImage>,
      reviews: null == reviews
          ? _value.reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<Review>,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoffeeShopImplCopyWith<$Res>
    implements $CoffeeShopCopyWith<$Res> {
  factory _$$CoffeeShopImplCopyWith(
          _$CoffeeShopImpl value, $Res Function(_$CoffeeShopImpl) then) =
      __$$CoffeeShopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String slug,
      String? address,
      String? district,
      String? phone,
      @JsonKey(name: 'image_url') String? imageUrl,
      String? description,
      @JsonKey(name: 'opening_hours') String? openingHours,
      @JsonKey(name: 'price_range') String? priceRange,
      String status,
      double? latitude,
      double? longitude,
      List<String> purposes,
      List<String> spaces,
      List<String> amenities,
      List<Drink> drinks,
      List<ShopImage> images,
      List<Review> reviews,
      @JsonKey(name: 'distance_km') double? distanceKm,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class __$$CoffeeShopImplCopyWithImpl<$Res>
    extends _$CoffeeShopCopyWithImpl<$Res, _$CoffeeShopImpl>
    implements _$$CoffeeShopImplCopyWith<$Res> {
  __$$CoffeeShopImplCopyWithImpl(
      _$CoffeeShopImpl _value, $Res Function(_$CoffeeShopImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoffeeShop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? address = freezed,
    Object? district = freezed,
    Object? phone = freezed,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? openingHours = freezed,
    Object? priceRange = freezed,
    Object? status = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? purposes = null,
    Object? spaces = null,
    Object? amenities = null,
    Object? drinks = null,
    Object? images = null,
    Object? reviews = null,
    Object? distanceKm = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$CoffeeShopImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      openingHours: freezed == openingHours
          ? _value.openingHours
          : openingHours // ignore: cast_nullable_to_non_nullable
              as String?,
      priceRange: freezed == priceRange
          ? _value.priceRange
          : priceRange // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      purposes: null == purposes
          ? _value._purposes
          : purposes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      spaces: null == spaces
          ? _value._spaces
          : spaces // ignore: cast_nullable_to_non_nullable
              as List<String>,
      amenities: null == amenities
          ? _value._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      drinks: null == drinks
          ? _value._drinks
          : drinks // ignore: cast_nullable_to_non_nullable
              as List<Drink>,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ShopImage>,
      reviews: null == reviews
          ? _value._reviews
          : reviews // ignore: cast_nullable_to_non_nullable
              as List<Review>,
      distanceKm: freezed == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoffeeShopImpl implements _CoffeeShop {
  const _$CoffeeShopImpl(
      {required this.id,
      required this.name,
      required this.slug,
      this.address,
      this.district,
      this.phone,
      @JsonKey(name: 'image_url') this.imageUrl,
      this.description,
      @JsonKey(name: 'opening_hours') this.openingHours,
      @JsonKey(name: 'price_range') this.priceRange,
      required this.status,
      this.latitude,
      this.longitude,
      final List<String> purposes = const [],
      final List<String> spaces = const [],
      final List<String> amenities = const [],
      final List<Drink> drinks = const [],
      final List<ShopImage> images = const [],
      final List<Review> reviews = const [],
      @JsonKey(name: 'distance_km') this.distanceKm,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _purposes = purposes,
        _spaces = spaces,
        _amenities = amenities,
        _drinks = drinks,
        _images = images,
        _reviews = reviews;

  factory _$CoffeeShopImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoffeeShopImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String? address;
  @override
  final String? district;
  @override
  final String? phone;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final String? description;
  @override
  @JsonKey(name: 'opening_hours')
  final String? openingHours;
  @override
  @JsonKey(name: 'price_range')
  final String? priceRange;
  @override
  final String status;
  @override
  final double? latitude;
  @override
  final double? longitude;
  final List<String> _purposes;
  @override
  @JsonKey()
  List<String> get purposes {
    if (_purposes is EqualUnmodifiableListView) return _purposes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_purposes);
  }

  final List<String> _spaces;
  @override
  @JsonKey()
  List<String> get spaces {
    if (_spaces is EqualUnmodifiableListView) return _spaces;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_spaces);
  }

  final List<String> _amenities;
  @override
  @JsonKey()
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  final List<Drink> _drinks;
  @override
  @JsonKey()
  List<Drink> get drinks {
    if (_drinks is EqualUnmodifiableListView) return _drinks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_drinks);
  }

  final List<ShopImage> _images;
  @override
  @JsonKey()
  List<ShopImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<Review> _reviews;
  @override
  @JsonKey()
  List<Review> get reviews {
    if (_reviews is EqualUnmodifiableListView) return _reviews;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reviews);
  }

  @override
  @JsonKey(name: 'distance_km')
  final double? distanceKm;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  @override
  String toString() {
    return 'CoffeeShop(id: $id, name: $name, slug: $slug, address: $address, district: $district, phone: $phone, imageUrl: $imageUrl, description: $description, openingHours: $openingHours, priceRange: $priceRange, status: $status, latitude: $latitude, longitude: $longitude, purposes: $purposes, spaces: $spaces, amenities: $amenities, drinks: $drinks, images: $images, reviews: $reviews, distanceKm: $distanceKm, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoffeeShopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.openingHours, openingHours) ||
                other.openingHours == openingHours) &&
            (identical(other.priceRange, priceRange) ||
                other.priceRange == priceRange) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality().equals(other._purposes, _purposes) &&
            const DeepCollectionEquality().equals(other._spaces, _spaces) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            const DeepCollectionEquality().equals(other._drinks, _drinks) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._reviews, _reviews) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        slug,
        address,
        district,
        phone,
        imageUrl,
        description,
        openingHours,
        priceRange,
        status,
        latitude,
        longitude,
        const DeepCollectionEquality().hash(_purposes),
        const DeepCollectionEquality().hash(_spaces),
        const DeepCollectionEquality().hash(_amenities),
        const DeepCollectionEquality().hash(_drinks),
        const DeepCollectionEquality().hash(_images),
        const DeepCollectionEquality().hash(_reviews),
        distanceKm,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of CoffeeShop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoffeeShopImplCopyWith<_$CoffeeShopImpl> get copyWith =>
      __$$CoffeeShopImplCopyWithImpl<_$CoffeeShopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoffeeShopImplToJson(
      this,
    );
  }
}

abstract class _CoffeeShop implements CoffeeShop {
  const factory _CoffeeShop(
          {required final int id,
          required final String name,
          required final String slug,
          final String? address,
          final String? district,
          final String? phone,
          @JsonKey(name: 'image_url') final String? imageUrl,
          final String? description,
          @JsonKey(name: 'opening_hours') final String? openingHours,
          @JsonKey(name: 'price_range') final String? priceRange,
          required final String status,
          final double? latitude,
          final double? longitude,
          final List<String> purposes,
          final List<String> spaces,
          final List<String> amenities,
          final List<Drink> drinks,
          final List<ShopImage> images,
          final List<Review> reviews,
          @JsonKey(name: 'distance_km') final double? distanceKm,
          @JsonKey(name: 'created_at') required final String createdAt,
          @JsonKey(name: 'updated_at') required final String updatedAt}) =
      _$CoffeeShopImpl;

  factory _CoffeeShop.fromJson(Map<String, dynamic> json) =
      _$CoffeeShopImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  String? get address;
  @override
  String? get district;
  @override
  String? get phone;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  String? get description;
  @override
  @JsonKey(name: 'opening_hours')
  String? get openingHours;
  @override
  @JsonKey(name: 'price_range')
  String? get priceRange;
  @override
  String get status;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  List<String> get purposes;
  @override
  List<String> get spaces;
  @override
  List<String> get amenities;
  @override
  List<Drink> get drinks;
  @override
  List<ShopImage> get images;
  @override
  List<Review> get reviews;
  @override
  @JsonKey(name: 'distance_km')
  double? get distanceKm;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt;

  /// Create a copy of CoffeeShop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoffeeShopImplCopyWith<_$CoffeeShopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
