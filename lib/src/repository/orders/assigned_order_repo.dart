import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../user_repository.dart' as userRepo;

/// Fetch orders that are already assigned to the driver (statuses 2 or 6).
/// Returns a map shaped like the backend response so it can be parsed by
/// `PendingOrdersModel.fromJson`.
Future<Map<String, dynamic>> getAssignedOrders({required String driverId}) async {
  final user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    print('❌ getAssignedOrders: missing api token');
    return {'orders': []};
  }

  final baseUrl = GlobalConfiguration().getValue('api_base_url');
  final url = '${baseUrl}driver/assigned-orders/$driverId';

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  try {
    final uri = Uri.parse(url).replace(queryParameters: {
      'api_token': user.apiToken!,
    });

    print('🔄 getAssignedOrders -> $uri');
    final response = await http.get(uri);

    print('🔍 getAssignedOrders status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final ordersData = jsonData['orders'] ?? [];

      if (ordersData is List) {
        final convertedOrders = ordersData.map((order) {
          return {
            'order_id': order['order_id'],
            'tax': _asDouble(order['tax']),
            'delivery_fee': _asDouble(order['delivery_fee']),
            'hint': order['hint'],
            'updated_at': order['updated_at'] ?? '',
            'order_status': order['order_status'] ?? {},
            'user': order['user'] ?? {},
            'food_orders': order['food_orders'] ?? [],
            'delivery_address': order['delivery_address'],
          };
        }).toList();

        return {'orders': convertedOrders};
      } else {
        print('❌ getAssignedOrders unexpected structure: $ordersData');
      }
    } else {
      print('❌ getAssignedOrders error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('❌ getAssignedOrders exception: $e');
  }

  return {'orders': []};
}

