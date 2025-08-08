import 'package:flutter/material.dart';

import 'package:deliveryboy/src/models/extra.dart';
import 'package:deliveryboy/src/models/media.dart';
import 'package:deliveryboy/src/models/restaurant.dart';

class Food {
  final int? id;
  final String? name;
  final double? price;
  final double? discountPrice;
  final String? description;
  final String? ingredients;
  final int? packageItemsCount;
  final int? weight;
  final String? unit;
  final bool? featured;
  final bool? deliverable;
  final int? restaurantId;
  final int? categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? estimatedTime;
  final List<dynamic>? customFields;
  final bool? hasMedia;
  final Restaurant? restaurant;
  final List<Media>? media;
  final List<Extra>? extras;

  Food({
    this.id,
    this.name,
    this.price,
    this.discountPrice,
    this.description,
    this.ingredients,
    this.packageItemsCount,
    this.weight,
    this.unit,
    this.featured,
    this.deliverable,
    this.restaurantId,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.estimatedTime,
    this.customFields,
    this.hasMedia,
    this.restaurant,
    this.media,
    this.extras,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json["id"],
        name: json["name"],
        price: (json["price"])?.toDouble(),
        discountPrice: (json["discount_price"])?.toDouble(),
        description: json["description"],
        ingredients: json["ingredients"],
        packageItemsCount: json["package_items_count"],
        weight: json["weight"],
        unit: json["unit"],
        featured: json["featured"],
        deliverable: json["deliverable"],
        restaurantId: json["restaurant_id"],
        categoryId: json["category_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        estimatedTime: json["estimated_time"],
        customFields: json["custom_fields"],
        hasMedia: json["has_media"],
        restaurant: json["restaurant"] == null
            ? null
            : Restaurant.fromJson(json["restaurant"]),
        extras: json["extras"] == null
            ? null
            : List<Extra>.from(json["extras"]!.map((x) => Extra.fromJSON(x))),
        media: json["media"] == null
            ? null
            : List<Media>.from(json["media"]!.map((x) => Media.fromJSON(x))),
      );

  Map<String, dynamic>? toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "discount_price": discountPrice,
        "description": description,
        "ingredients": ingredients,
        "package_items_count": packageItemsCount,
        "weight": weight,
        "unit": unit,
        "featured": featured,
        "deliverable": deliverable,
        "restaurant_id": restaurantId,
        "category_id": categoryId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "estimated_time": estimatedTime,
        "custom_fields": customFields,
        "has_media": hasMedia,
        "restaurant": restaurant?.toJson(),
        "extras": extras == null
            ? null
            : List<dynamic>.from(extras!.map((x) => x.toMap())),
        "media": media == null
            ? null
            : List<dynamic>.from(media!.map((x) => x.toMap())),
      };

  Food copyWith({
    ValueGetter<int?>? id,
    ValueGetter<String?>? name,
    ValueGetter<double?>? price,
    ValueGetter<double?>? discountPrice,
    ValueGetter<String?>? description,
    ValueGetter<String?>? ingredients,
    ValueGetter<int?>? packageItemsCount,
    ValueGetter<int?>? weight,
    ValueGetter<String?>? unit,
    ValueGetter<bool?>? featured,
    ValueGetter<bool?>? deliverable,
    ValueGetter<int?>? restaurantId,
    ValueGetter<int?>? categoryId,
    ValueGetter<DateTime?>? createdAt,
    ValueGetter<DateTime?>? updatedAt,
    ValueGetter<int?>? estimatedTime,
    ValueGetter<List<dynamic>?>? customFields,
    ValueGetter<bool?>? hasMedia,
    ValueGetter<Restaurant?>? restaurant,
    ValueGetter<List<Media>?>? media,
    ValueGetter<List<Extra>?>? extras,
  }) {
    return Food(
      id: id != null ? id() : this.id,
      name: name != null ? name() : this.name,
      price: price != null ? price() : this.price,
      discountPrice:
          discountPrice != null ? discountPrice() : this.discountPrice,
      description: description != null ? description() : this.description,
      ingredients: ingredients != null ? ingredients() : this.ingredients,
      packageItemsCount: packageItemsCount != null
          ? packageItemsCount()
          : this.packageItemsCount,
      weight: weight != null ? weight() : this.weight,
      unit: unit != null ? unit() : this.unit,
      featured: featured != null ? featured() : this.featured,
      deliverable: deliverable != null ? deliverable() : this.deliverable,
      restaurantId: restaurantId != null ? restaurantId() : this.restaurantId,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      estimatedTime:
          estimatedTime != null ? estimatedTime() : this.estimatedTime,
      customFields: customFields != null ? customFields() : this.customFields,
      hasMedia: hasMedia != null ? hasMedia() : this.hasMedia,
      restaurant: restaurant != null ? restaurant() : this.restaurant,
      media: media != null ? media() : this.media,
      extras: extras != null ? extras() : this.extras,
    );
  }
}
