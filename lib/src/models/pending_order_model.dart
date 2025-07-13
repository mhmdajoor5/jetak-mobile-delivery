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
  String customerName;
  String address;
  double latitude;
  double longitude;

  PendingOrderModel({
    required this.orderId,
    required this.customerName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PendingOrderModel.fromJson(Map<String, dynamic> json) =>
      PendingOrderModel(
        orderId: json["order_id"] ?? 0,
        customerName: json["customer_name"] ?? "Unknown Customer",
        address: json["address"] ?? "Address not provided",
        latitude: (json["latitude"] ?? 0.0).toDouble(),
        longitude: (json["longitude"] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "customer_name": customerName,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
  };
}
