// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../helpers/custom_trace.dart';

class OrderStatus {
  String? id;
  String? status;

  OrderStatus();

  OrderStatus.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString() ?? '';
      status = jsonMap['status']?.toString() ?? '';
    } catch (e) {
      id = '';
      status = '';
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  @override
  String toString() => 'OrderStatus(id: $id, status: $status)';
}
