
import 'dart:convert';

import 'package:deliveryboy/src/models/pending_order_model.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getPendingOrders({required String driverId}) async {
  print('getPendingOrders : waiting');
  final response = await http.post(
    Uri.parse('https://carrytechnologies.co/api/driver/driver-candidate-orders/5'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "api_token": "OuMsmU903WMcMhzAbuSFtxBekZVdXz66afifRo3YRCINi38jkXJ8rpN0FcfS",
    }),
  );

  if (response.statusCode == 200) {
    print('getPendingOrders : success');
    print(json.decode(response.body));
    return json.decode(response.body);
  } else {
    print('getPendingOrders : error ${response.statusCode}');
    throw Exception('Failed to load pending orders');
  }
}
