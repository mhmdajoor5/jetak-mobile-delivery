import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_history_model.dart';

class OrderHistoryController {
  // ضع رابط الـ API هنا
  String apiUrl = '';

  Future<List<OrderHistoryModel>> getOrdersHistory() async {
    if (apiUrl.isEmpty) {
      // إذا لم يتم وضع رابط API، يرجع قائمة فارغة
      return [];
    }
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderHistoryModel.fromJson(json)).toList();
    } else {
      throw Exception('فشل في جلب البيانات');
    }
  }
} 