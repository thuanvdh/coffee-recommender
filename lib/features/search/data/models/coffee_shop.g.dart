// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coffee_shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewImpl _$$ReviewImplFromJson(Map<String, dynamic> json) => _$ReviewImpl(
      id: (json['id'] as num).toInt(),
      userName: json['user_name'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$ReviewImplToJson(_$ReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_name': instance.userName,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt,
    };

_$DrinkImpl _$$DrinkImplFromJson(Map<String, dynamic> json) => _$DrinkImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      price: json['price'] as String?,
      category: json['category'] as String? ?? 'drink',
      isSignature: json['is_signature'] as bool? ?? false,
      isTrending: json['is_trending'] as bool? ?? false,
    );

Map<String, dynamic> _$$DrinkImplToJson(_$DrinkImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'category': instance.category,
      'is_signature': instance.isSignature,
      'is_trending': instance.isTrending,
    };

_$ShopImageImpl _$$ShopImageImplFromJson(Map<String, dynamic> json) =>
    _$ShopImageImpl(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      altText: json['alt_text'] as String?,
    );

Map<String, dynamic> _$$ShopImageImplToJson(_$ShopImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'alt_text': instance.altText,
    };

_$CoffeeShopImpl _$$CoffeeShopImplFromJson(Map<String, dynamic> json) =>
    _$CoffeeShopImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      address: json['address'] as String?,
      district: json['district'] as String?,
      phone: json['phone'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      openingHours: json['opening_hours'] as String?,
      priceRange: json['price_range'] as String?,
      status: json['status'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      purposes: (json['purposes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      spaces: (json['spaces'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      drinks: (json['drinks'] as List<dynamic>?)
              ?.map((e) => Drink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ShopImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$CoffeeShopImplToJson(_$CoffeeShopImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'address': instance.address,
      'district': instance.district,
      'phone': instance.phone,
      'image_url': instance.imageUrl,
      'description': instance.description,
      'opening_hours': instance.openingHours,
      'price_range': instance.priceRange,
      'status': instance.status,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'purposes': instance.purposes,
      'spaces': instance.spaces,
      'amenities': instance.amenities,
      'drinks': instance.drinks,
      'images': instance.images,
      'reviews': instance.reviews,
      'distance_km': instance.distanceKm,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
