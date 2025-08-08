// To parse this JSON data, do
//
//     final orderHistoryResponse = orderHistoryResponseFromJson(jsonString);

import 'dart:convert';
import 'package:deliveryboy/src/models/address.dart';
import 'package:deliveryboy/src/models/order_status.dart';
import 'package:deliveryboy/src/models/user.dart';
import 'package:intl/intl.dart';

import 'food_order.dart';

OrderHistoryResponse? orderHistoryResponseFromJson(String str) {
  try {
    return OrderHistoryResponse.fromJson(json.decode(str));
  } catch (e) {
    return null;
  }
}

String orderHistoryResponseToJson(OrderHistoryResponse? data) =>
    json.encode(data?.toJson());

class OrderHistoryResponse {
  final bool? success;
  final List<OrderHistoryModel>? data;

  OrderHistoryResponse({
    this.success,
    this.data,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) =>
      OrderHistoryResponse(
        success: json["success"],
        data: json["data"] == null
            ? null
            : List<OrderHistoryModel>.from(
                json["data"]!.map((x) => OrderHistoryModel.fromJson(x))),
      );

  Map<String, dynamic>? toJson() => {
        "success": success,
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class OrderHistoryModel {
  final int? id;
  final int? userId;
  final int? orderStatusId;
  final double? tax;
  final double? deliveryFee;
  final String? hint;
  final bool? active;
  final int? driverId;
  final int? deliveryAddressId;
  final int? paymentId;
  final String? hashId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? preparationDuration;
  final int? preparationPenalty;
  final String? orderType;
  final List<dynamic>? customFields;
  final Driver? driver;
  final List<FoodOrder>? foodOrders;
  final OrderStatus? orderStatus;
  final Address? deliveryAddress;
  final dynamic payment;
  final double? foodTotal;
  final String? status;
  final DateTime? date;
  final double? amount;
  final User? user;

  OrderHistoryModel({
    this.id,
    this.userId,
    this.orderStatusId,
    this.tax,
    this.deliveryFee,
    this.hint,
    this.active,
    this.driverId,
    this.deliveryAddressId,
    this.paymentId,
    this.hashId,
    this.createdAt,
    this.updatedAt,
    this.preparationDuration,
    this.preparationPenalty,
    this.orderType,
    this.customFields,
    this.driver,
    this.foodOrders,
    this.orderStatus,
    this.deliveryAddress,
    this.payment,
    this.foodTotal,
    this.status,
    this.date,
    this.amount,
    this.user,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) =>
      OrderHistoryModel(
        id: json["id"],
        userId: json["user_id"],
        orderStatusId: json["order_status_id"],
        tax: (json["tax"])?.toDouble(),
        deliveryFee: (json["delivery_fee"])?.toDouble(),
        hint: json["hint"],
        active: json["active"],
        driverId: json["driver_id"],
        deliveryAddressId: json["delivery_address_id"],
        paymentId: json["payment_id"],
        hashId: json["hash_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        preparationDuration: json["preparation_duration"],
        preparationPenalty: json["preparation_penalty"],
        orderType: json["order_type"],
        customFields: json["custom_fields"],
        driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
        foodOrders: json["food_orders"] == null
            ? null
            : List<FoodOrder>.from(
                json["food_orders"]!.map((x) => FoodOrder.fromJson(x))),
        orderStatus: json["order_status"] == null ? null : OrderStatus.fromJSON(json["order_status"]),
        deliveryAddress: json["delivery_address"] == null
            ? null
            : Address.fromJSON(json["delivery_address"]),
        payment: json["payment"],
        foodTotal: (json["food_total"])?.toDouble(),
        status: json["status"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
          );

  Map<String, dynamic>? toJson() => {
        "id": id,
        "user_id": userId,
        "order_status_id": orderStatusId,
        "tax": tax,
        "delivery_fee": deliveryFee,
        "hint": hint,
        "active": active,
        "driver_id": driverId,
        "delivery_address_id": deliveryAddressId,
        "payment_id": paymentId,
        "hash_id": hashId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "preparation_duration": preparationDuration,
        "preparation_penalty": preparationPenalty,
        "order_type": orderType,
        "custom_fields": customFields,
        "driver": driver?.toJson(),
        "food_orders": foodOrders == null
            ? null
            : List<dynamic>.from(foodOrders!.map((x) => x.toJson())),
        "order_status": orderStatus?.toMap(),
        "delivery_address": deliveryAddress?.toMap(),
        "payment": payment,
        "food_total": foodTotal,
        "date": date?.toIso8601String(),
      };

  // Formatted date string
  String get formattedDate {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(date!);
    } catch (e) {
      return date.toString();
    }
  }

  // Formatted amount with currency
  String get formattedAmount {
    return '${amount?.toStringAsFixed(2)} ₪';
  }

  // Short date for compact display
  String get shortDate {
    try {
      return DateFormat('dd/MM/yyyy').format(date!);
    } catch (e) {
      return date.toString().split(' ')[0];
    }
  }

  // Time only
  String get timeOnly {
    try {
      return DateFormat('HH:mm').format(date!);
    } catch (e) {
      return '';
    }
  }

  // Status color based on status name
  String get statusColor {
    if (status == null ) return 'grey';
    switch (status!.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return 'green';
      case 'pending':
        return 'orange';
      case 'cancelled':
      case 'rejected':
        return 'red';
      case 'preparing':
      case 'accepted':
        return 'blue';
      case 'ready':
      case 'ready for pickup':
        return 'purple';
      case 'on the way':
      case 'in delivery':
        return 'indigo';
      default:
        return 'grey';
    }
  }

  // Status icon based on status name
  String get statusIcon {
    if (status == null ) return 'help_outline';
    switch (status?.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return 'check_circle';
      case 'pending':
        return 'schedule';
      case 'cancelled':
      case 'rejected':
        return 'cancel';
      case 'preparing':
      case 'accepted':
        return 'restaurant';
      case 'ready':
      case 'ready for pickup':
        return 'assignment_turned_in';
      case 'on the way':
      case 'in delivery':
        return 'local_shipping';
      default:
        return 'help_outline';
    }
  }

}

class Driver {
  final int? id;
  final String? name;
  final String? email;
  final String? apiToken;
  final String? deviceToken;
  final String? stripeId;
  final String? cardBrand;
  final String? cardLastFour;
  final String? trialEndsAt;
  final String? braintreeId;
  final String? paypalEmail;
  final String? code;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DriverCustomFields? customFields;
  final bool? hasMedia;
  final List<dynamic>? media;

  Driver({
    this.id,
    this.name,
    this.email,
    this.apiToken,
    this.deviceToken,
    this.stripeId,
    this.cardBrand,
    this.cardLastFour,
    this.trialEndsAt,
    this.braintreeId,
    this.paypalEmail,
    this.code,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.customFields,
    this.hasMedia,
    this.media,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        apiToken: json["api_token"],
        deviceToken: json["device_token"],
        stripeId: json["stripe_id"],
        cardBrand: json["card_brand"],
        cardLastFour: json["card_last_four"],
        trialEndsAt: json["trial_ends_at"],
        braintreeId: json["braintree_id"],
        paypalEmail: json["paypal_email"],
        code: json["code"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        customFields: json["custom_fields"] == null
            ? null
            : DriverCustomFields.fromJson(json["custom_fields"]),
        hasMedia: json["has_media"],
        media: json["media"],
      );

  Map<String, dynamic>? toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "api_token": apiToken,
        "device_token": deviceToken,
        "stripe_id": stripeId,
        "card_brand": cardBrand,
        "card_last_four": cardLastFour,
        "trial_ends_at": trialEndsAt,
        "braintree_id": braintreeId,
        "paypal_email": paypalEmail,
        "code": code,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "custom_fields": customFields?.toJson(),
        "has_media": hasMedia,
        "media": media,
      };
}

class DriverCustomFields {
  final CustomField? phone;
  final CustomField? bio;
  final CustomField? address;
  final CustomField? verifiedPhone;

  DriverCustomFields({
    this.phone,
    this.bio,
    this.address,
    this.verifiedPhone,
  });

  factory DriverCustomFields.fromJson(Map<String, dynamic> json) =>
      DriverCustomFields(
        phone: json["phone"] == null ? null : CustomField.fromJson(json["phone"]),
        bio: json["bio"] == null ? null : CustomField.fromJson(json["bio"]),
        address: json["address"] == null ? null : CustomField.fromJson(json["address"]),
        verifiedPhone: json["verifiedPhone"] == null ? null : CustomField.fromJson(json["verifiedPhone"]),
      );

  Map<String, dynamic>? toJson() => {
        "phone": phone?.toJson(),
        "bio": bio?.toJson(),
        "address": address?.toJson(),
        "verifiedPhone": verifiedPhone?.toJson(),
      };
}

class CustomField {
  final String? value;
  final String? view;
  final String? name;

  CustomField({
    this.value,
    this.view,
    this.name,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        value: json["value"],
        view: json["view"],
        name: json["name"],
      );

  Map<String, dynamic>? toJson() => {
        "value": value,
        "view": view,
        "name": name,
      };
}

class CustomProperties {
  final String? uuid;
  final int? userId;
  final GeneratedConversions? generatedConversions;

  CustomProperties({
    this.uuid,
    this.userId,
    this.generatedConversions,
  });

  factory CustomProperties.fromJson(Map<String, dynamic> json) =>
      CustomProperties(
        uuid: json["uuid"],
        userId: json["user_id"],
        generatedConversions: json["generated_conversions"] == null
            ? null
            : GeneratedConversions.fromJson(json["generated_conversions"]),
      );

  Map<String, dynamic>? toJson() => {
        "uuid": uuid,
        "user_id": userId,
        "generated_conversions": generatedConversions?.toJson(),
      };
}

class GeneratedConversions {
  final bool? thumb;
  final bool? icon;

  GeneratedConversions({
    this.thumb,
    this.icon,
  });

  factory GeneratedConversions.fromJson(Map<String, dynamic> json) =>
      GeneratedConversions(
        thumb: json["thumb"],
        icon: json["icon"],
      );

  Map<String, dynamic>? toJson() => {
        "thumb": thumb,
        "icon": icon,
      };
}
