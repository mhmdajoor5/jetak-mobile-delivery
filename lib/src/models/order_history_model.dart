import 'package:deliveryboy/src/models/food_order.dart';
import 'package:intl/intl.dart';

class OrderHistoryModel {
  final String orderNumber;
  final String clientName;
  final String phoneNumber;
  final String deliveryAddress;
  final DateTime date;
  final double amount;
  final String status;

  final List<FoodOrder>? foodOrders;
  
  OrderHistoryModel({
    required this.orderNumber,
    required this.clientName,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.date,
    required this.amount,
    required this.status,
    required this.foodOrders,
  });

  // Formatted date string
  String get formattedDate {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return date.toString();
    }
  }

  // Formatted amount with currency
  String get formattedAmount {
    return '${amount.toStringAsFixed(2)} ₪';
  }

  // Short date for compact display
  String get shortDate {
    try {
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return date.toString().split(' ')[0];
    }
  }

  // Time only
  String get timeOnly {
    try {
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return '';
    }
  }

  // Status color based on status name
  String get statusColor {
    switch (status.toLowerCase()) {
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
    switch (status.toLowerCase()) {
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

  // Convert to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'clientName': clientName,
      'phoneNumber': phoneNumber,
      'deliveryAddress': deliveryAddress,
      'date': date.toIso8601String(),
      'amount': amount,
      'foodOrders': foodOrders,
      'status': status,
    };
  }

  // Create from Map (JSON deserialization)
  factory OrderHistoryModel.fromMap(Map<String, dynamic> map) {
    return OrderHistoryModel(
      orderNumber: map['orderNumber'] ?? '',
      clientName: map['clientName'] ?? 'غير محدد',
      phoneNumber: map['phoneNumber'] ?? 'غير محدد',
      deliveryAddress: map['deliveryAddress'] ?? 'غير محدد',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'غير محدد',
      foodOrders: map['foodOrders'] != null
          ? List.from(map['foodOrders']).map((element) => FoodOrder.fromJSON(element)).toList()
          : <FoodOrder>[],
      
    );
  }

  // Copy with method for modifications
  OrderHistoryModel copyWith({
    String? orderNumber,
    String? clientName,
    String? phoneNumber,
    String? deliveryAddress,
    DateTime? date,
    double? amount,
    String? status,
  }) {
    return OrderHistoryModel(
      orderNumber: orderNumber ?? this.orderNumber,
      clientName: clientName ?? this.clientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      foodOrders: foodOrders ?? this.foodOrders,
    );
  }

  @override
  String toString() {
    return 'OrderHistoryModel(orderNumber: $orderNumber, clientName: $clientName, status: $status, amount: $formattedAmount, date: $formattedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderHistoryModel && other.orderNumber == orderNumber;
  }

  @override
  int get hashCode {
    return orderNumber.hashCode;
  }
} 