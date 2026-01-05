
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_repository.dart' as userRepo;

Future<Map<String, dynamic>> getPendingOrders({required String driverId}) async {
  print('🔄 getPendingOrders: starting request for driver $driverId');
  
  final user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    print('❌ No API token available');
    return {'orders': []};
  }

  try {
    // استخدام API endpoint الصحيح للطلبات المعلقة
    final baseUrl = GlobalConfiguration().getValue('api_base_url');
    final url = '${baseUrl}driver/driver-candidate-orders/$driverId';
    
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'api_token': user.apiToken!,
        'with': 'user;foodOrders;foodOrders.food;orderStatus;deliveryAddress;payment',
        // 'search': 'driver_id:null;order_status_id:1', // طلبات بدون سائق و pending
        'searchFields': 'driver_id:=;order_status_id:=',
        'searchJoin': 'and',
        'orderBy': 'id',
        'sortedBy': 'desc',
        'limit': '20'
      }),
     
      headers: {'Content-Type': 'application/json'},
    );

    print('🔍 API URL: $url');
    print('🔍 API Response Status: ${response.statusCode}');
    print('🔍 API Response Headers: ${response.headers}');
    
    if (response.statusCode == 200) {
      print('✅ getPendingOrders: success');
      
      final jsonData = json.decode(response.body);
      print('📦 Raw JSON Response:');
      print(jsonData);
      
      // تحويل البيانات لتتناسب مع PendingOrderModel
      final ordersData = jsonData['orders'] ?? [];
      
      if (ordersData is List) {
        print('📋 Found ${ordersData.length} pending orders');
        
        // تحويل البيانات لصيغة PendingOrderModel
        final convertedOrders = ordersData.map((order) {
          print('🔍 Converting Order ${order['order_id']}:');
          print('  - User: ${order['user']}');
          print('  - Delivery Address: ${order['delivery_address']}');
          
          return {
            'order_id': order['order_id'],
            'tax': (order['tax'] ?? 0.0).toDouble(),
            'delivery_fee': (order['delivery_fee'] ?? 0.0).toDouble(),
            'hint': order['hint'],
            'updated_at': order['updated_at'] ?? DateTime.now().toIso8601String(),
            'order_status': order['order_status'] ?? {'id': 1, 'status': 'Pending'},
            'user': order['user'] ?? {},
            'food_orders': order['food_orders'] ?? [],
            'delivery_address': order['delivery_address'],
          };
        }).toList();
        
        return {'orders': convertedOrders};
      } else {
        print('❌ Unexpected data structure: $ordersData');
        return {'orders': []};
      }
    } else {
      print('❌ getPendingOrders: error ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      
      // إرجاع بيانات وهمية للاختبار
      return {};
    }
  } catch (e) {
    print('❌ Exception in getPendingOrders: $e');
    return {};
  }
}

// دالة قبول الطلب
Future<Map<String, dynamic>> acceptOrder({required String orderId}) async {
  print('🔄 acceptOrder: accepting order $orderId');
  
  final user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return {'success': false, 'message': 'Authentication required'};
  }

  try {
    final response = await http.post(
      Uri.parse('https://carrytechnologies.co/api/driver/accept-order-by-driver'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'order_id': orderId,
        'api_token': user.apiToken!,
      }),
    );

    print('🔍 Accept Order Response Status: ${response.statusCode}');
    print('🔍 Accept Order Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('✅ Order $orderId accepted successfully');
      
      // Save the accepted order ID to SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_order_id', int.tryParse(orderId) ?? 0);
        print('✅ Saved last_order_id: $orderId to SharedPreferences');
      } catch (e) {
        print('❌ Error saving last_order_id to SharedPreferences: $e');
      }
      
      return {'success': true, 'message': 'Order accepted successfully', 'data': jsonData};
    } else {
      print('❌ Failed to accept order: ${response.statusCode}');
      return {'success': false, 'message': 'Failed to accept order: ${response.statusCode}'};
    }
  } catch (e) {
    print('❌ Exception accepting order: $e');
    return {'success': false, 'message': 'Network error: $e'};
  }
}

// دالة رفض الطلب
Future<Map<String, dynamic>> rejectOrder({required String orderId}) async {
  print('🔄 rejectOrder: rejecting order $orderId');
  
  final user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return {'success': false, 'message': 'Authentication required'};
  }

  try {
    final response = await http.post(
      Uri.parse('https://carrytechnologies.co/api/driver/reject-order-by-driver'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'order_id': orderId,
        'api_token': user.apiToken!,
      }),
    );

    print('🔍 Reject Order Response Status: ${response.statusCode}');
    print('🔍 Reject Order Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('✅ Order $orderId rejected successfully');
      return {'success': true, 'message': 'Order rejected successfully', 'data': jsonData};
    } else {
      print('❌ Failed to reject order: ${response.statusCode}');
      return {'success': false, 'message': 'Failed to reject order: ${response.statusCode}'};
    }
  } catch (e) {
    print('❌ Exception rejecting order: $e');
    return {'success': false, 'message': 'Network error: $e'};
  }
}

// // بيانات وهمية للاختبار
// Map<String, dynamic> _getMockPendingOrders() {
//   print('🔄 Returning mock pending orders for testing...');
//   return {
//     'orders': [
//       {
//         'order_id': 123,
//         'tax': 5.0,
//         'delivery_fee': 10.0,
//         'hint': 'طلب تجريبي - قرب الباب الرئيسي',
//         'updated_at': DateTime.now().toIso8601String(),
//         'order_status': {'id': 1, 'status': 'Pending'},
//         'user': {
//           'id': 456,
//           'name': 'أحمد محمد العميل',
//           'phone': '+970599123456',
//           'email': 'ahmed@example.com',
//         },
//         'food_orders': [
//           {
//             'id': 789,
//             'quantity': 2,
//             'price': 15.0,
//             'food': {'id': 101, 'name': 'شاورما لحمة', 'price': 7.5},
//           },
//           {
//             'id': 790,
//             'quantity': 1,
//             'price': 8.0,
//             'food': {'id': 102, 'name': 'عصير برتقال', 'price': 8.0},
//           }
//         ],
//         'delivery_address': {
//           'id': 999,
//           'address': 'شارع عمر المختار، بناية النور، الطابق الثالث، غزة',
//           'latitude': 31.5017,
//           'longitude': 34.4668,
//         }
//       },
//       {
//         'order_id': 124,
//         'tax': 3.0,
//         'delivery_fee': 8.0,
//         'hint': 'عند الإشارة الضوئية',
//         'updated_at': DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
//         'order_status': {'id': 1, 'status': 'Pending'},
//         'user': {
//           'id': 457,
//           'name': 'فاطمة أحمد',
//           'phone': '+970599654321',
//           'email': 'fatima@example.com',
//         },
//         'food_orders': [
//           {
//             'id': 791,
//             'quantity': 1,
//             'price': 25.0,
//             'food': {'id': 103, 'name': 'بيتزا مارجريتا', 'price': 25.0},
//           }
//         ],
//         'delivery_address': {
//           'id': 1000,
//           'address': 'حي الرمال، شارع الجلاء، بجانب مسجد النور، غزة',
//           'latitude': 31.5203,
//           'longitude': 34.4776,
//         }
//       }
//     ]
//   };
// }
