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
        orderId: json["order_id"],
        customerName: json["customer_name"],
        address: json["address"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "customer_name": customerName,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
  };
}
