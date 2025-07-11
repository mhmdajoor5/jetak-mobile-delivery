class OrderHistoryModel {
  final String orderId;
  final String client;
  final String phone;
  final String status;

  OrderHistoryModel({
    required this.orderId,
    required this.client,
    required this.phone,
    required this.status,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      orderId: json['orderId'] ?? '',
      client: json['client'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'client': client,
      'phone': phone,
      'status': status,
    };
  }
} 