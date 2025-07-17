class OrderStatusHistoryItem {
  final String id;
  final String status;
  final String statusName;
  final DateTime timestamp;
  final String? notes;
  final String? updatedBy;

  OrderStatusHistoryItem({
    required this.id,
    required this.status,
    required this.statusName,
    required this.timestamp,
    this.notes,
    this.updatedBy,
  });

  factory OrderStatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryItem(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusName: json['status_name']?.toString() ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      notes: json['notes']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'status_name': statusName,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'updated_by': updatedBy,
    };
  }
}

class OrderStatusHistory {
  final String orderId;
  final List<OrderStatusHistoryItem> statusHistory;

  OrderStatusHistory({
    required this.orderId,
    required this.statusHistory,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    var historyList = json['status_history'] as List<dynamic>? ?? [];
    
    return OrderStatusHistory(
      orderId: json['order_id']?.toString() ?? '',
      statusHistory: historyList
          .map((item) => OrderStatusHistoryItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'status_history': statusHistory.map((item) => item.toJson()).toList(),
    };
  }
} 