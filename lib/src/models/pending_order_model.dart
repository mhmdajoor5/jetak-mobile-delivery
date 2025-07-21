// To parse this JSON data, do
//
//     final PendingOrdersModel = PendingOrdersModelFromJson(jsonString);

import 'dart:convert';

PendingOrdersModel PendingOrdersModelFromJson(String str) =>
    PendingOrdersModel.fromJson(json.decode(str));

String PendingOrdersModelToJson(PendingOrdersModel data) =>
    json.encode(data.toJson());

class PendingOrdersModel {
  List<PendingOrderModel> orders;

  PendingOrdersModel({required this.orders});

  factory PendingOrdersModel.fromJson(Map<String, dynamic> json) =>
      PendingOrdersModel(
        orders: List<PendingOrderModel>.from(
          json["orders"].map((x) => PendingOrderModel.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
  };
}

class PendingOrderModel {
  int orderId;
  double tax;
  double deliveryFee;
  String? hint;
  String updatedAt;
  OrderStatus orderStatus;
  OrderUser user;
  List<FoodOrder> foodOrders;
  DeliveryAddress? deliveryAddress;

  PendingOrderModel({
    required this.orderId,
    required this.tax,
    required this.deliveryFee,
    this.hint,
    required this.updatedAt,
    required this.orderStatus,
    required this.user,
    required this.foodOrders,
    this.deliveryAddress,
  });

  factory PendingOrderModel.fromJson(Map<dynamic, dynamic> json) =>
      PendingOrderModel(
        orderId: json["order_id"] ?? 0,
        tax: (json["tax"] ?? 0.0).toDouble(),
        deliveryFee: (json["delivery_fee"] ?? 0.0).toDouble(),
        hint: json["hint"],
        updatedAt: json["updated_at"] ?? "",
        orderStatus: OrderStatus.fromJson(json["order_status"] ?? {}),
        user: OrderUser.fromJson(json["user"] ?? {}),
        foodOrders: List<FoodOrder>.from((json["food_orders"] ?? []).map((x) => FoodOrder.fromJson(x))),
        deliveryAddress: json["delivery_address"] != null ? DeliveryAddress.fromJson(json["delivery_address"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "tax": tax,
    "delivery_fee": deliveryFee,
    "hint": hint,
    "updated_at": updatedAt,
    "order_status": orderStatus.toJson(),
    "user": user.toJson(),
    "food_orders": List<dynamic>.from(foodOrders.map((x) => x.toJson())),
    "delivery_address": deliveryAddress?.toJson(),
  };

  // Helper getters for backward compatibility
  String get customerName => user.name;
  String get address => deliveryAddress?.address ?? "Address not available";
  double get latitude => deliveryAddress?.latitude ?? 0.0;
  double get longitude => deliveryAddress?.longitude ?? 0.0;
}

class OrderStatus {
  int id;
  String status;

  OrderStatus({
    required this.id,
    required this.status,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) =>
      OrderStatus(
        id: json["id"] ?? 0,
        status: json["status"] ?? "Unknown",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
  };
}

class OrderUser {
  int id;
  String name;
  String? phone;
  String email;

  OrderUser({
    required this.id,
    required this.name,
    this.phone,
    required this.email,
  });

  factory OrderUser.fromJson(Map<dynamic, dynamic> json) =>
      OrderUser(
        id: json["id"] ?? 0,
        name: json["name"] ?? "Unknown Customer",
        phone: json["phone"], // Can be null
        email: json["email"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
  };
}

class FoodOrder {
  int id;
  int quantity;
  double price;
  Food food;

  FoodOrder({
    required this.id,
    required this.quantity,
    required this.price,
    required this.food,
  });

  factory FoodOrder.fromJson(Map<String, dynamic> json) =>
      FoodOrder(
        id: json["id"] ?? 0,
        quantity: json["quantity"] ?? 0,
        price: (json["price"] ?? 0.0).toDouble(),
        food: Food.fromJson(json["food"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "price": price,
    "food": food.toJson(),
  };
}

class Food {
  int id;
  String name;
  double price;

  Food({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Food.fromJson(Map<String, dynamic> json) =>
      Food(
        id: json["id"] ?? 0,
        name: json["name"] ?? "Unknown Food",
        price: (json["price"] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
  };
}

class DeliveryAddress {
  int id;
  String address;
  double latitude;
  double longitude;

  DeliveryAddress({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        id: json["id"] ?? 0,
        address: json["address"] ?? "Address not provided",
        latitude: (json["latitude"] ?? 0.0).toDouble(),
        longitude: (json["longitude"] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
  };
}
