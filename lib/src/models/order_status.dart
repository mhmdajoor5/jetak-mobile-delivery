

                // ignore_for_file: public_member_api_docs, sort_constructors_first

import '../helpers/custom_trace.dart';

class OrderStatus {
  String? id;
  String? status;
  DateTime? createdAt;      // New field
  DateTime? updatedAt;      // New field
  List<dynamic>? customFields; // New field

  OrderStatus();

  OrderStatus.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString() ?? '';
      status = jsonMap['status']?.toString() ?? '';
      
      // New fields from the extended JSON
      createdAt = jsonMap['created_at'] != null ? DateTime.parse(jsonMap['created_at']) : null;
      updatedAt = jsonMap['updated_at'] != null ? DateTime.parse(jsonMap['updated_at']) : null;
      customFields = jsonMap['custom_fields'];

    } catch (e) {
      id = '';
      status = '';
      createdAt = null;
      updatedAt = null;
      customFields = null;
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["status"] = status;
    map["created_at"] = createdAt?.toIso8601String();
    map["updated_at"] = updatedAt?.toIso8601String();
    map["custom_fields"] = customFields;
    return map;
  }

  @override
  String toString() => 'OrderStatus(id: $id, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';

   
  // CopyWith Method
  OrderStatus copyWith({
    String? id,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<dynamic>? customFields,
  }) {
    OrderStatus order = OrderStatus();
    order.id = id ?? this.id;
    order.status = status ?? this.status;
    order.createdAt = createdAt ?? this.createdAt;
    order.updatedAt = updatedAt ?? this.updatedAt;
    order.customFields = customFields ?? this.customFields;
    return order;
  }
}