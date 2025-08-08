// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../models/food.dart';

class FoodOrder {
  final int? id;
  final double? price;
  final int? quantity;
  final int? foodId;
  final int? orderId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<dynamic>? customFields;
  final Food? food;
  final List<dynamic>? extras;

  FoodOrder({
    this.id,
    this.price,
    this.quantity,
    this.foodId,
    this.orderId,
    this.createdAt,
    this.updatedAt,
    this.customFields,
    this.food,
    this.extras,
  });

  factory FoodOrder.fromJson(Map<String, dynamic> json) => FoodOrder(
        id: json["id"],
        price: (json["price"])?.toDouble(),
        quantity: json["quantity"],
        foodId: json["food_id"],
        orderId: json["order_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        customFields: json["custom_fields"],
        food: json["food"] == null ? null : Food.fromJson(json["food"]),
        extras: json["extras"],
      );

  Map<String, dynamic>? toJson() => {
        "id": id,
        "price": price,
        "quantity": quantity,
        "food_id": foodId,
        "order_id": orderId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "custom_fields": customFields,
        "food": food?.toJson(),
        "extras": extras,
      };
}
