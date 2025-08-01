import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/order_status_history.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;
Future<bool> changeOrderStatus({required int statusId})async{
  Uri uri = Helper.getUri('Api/driver/orders/$statusId');
  Map<String, dynamic> queryParams = {};
  User user = userRepo.currentUser.value;

  queryParams['api_token'] = user.apiToken;
  uri = uri.replace(queryParameters: queryParams);

  try {
    final res = await http.get(uri);
    final data = json.decode(res.body);
    if(res.statusCode == 200){
      return true;
    }
    return false;

  }catch(e){
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return false;
  }
}
Future<Stream<Order>> getOrders() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> queryParams = {};
  final String orderStatusId = "5"; // for delivered status
  User user = userRepo.currentUser.value;

  queryParams['api_token'] = user.apiToken;
  queryParams['with'] =
      'driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  queryParams['search'] =
      'driver.id:${user.id};order_status_id:$orderStatusId;delivery_address_id:null';
  queryParams['searchFields'] =
      'driver.id:=;order_status_id:<>;delivery_address_id:<>';
  queryParams['searchJoin'] = 'and';
  queryParams['orderBy'] = 'id';
  queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: queryParams);
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String, dynamic>))
        .expand((data) => (data as List))
        .map((data) {
          return Order.fromJSON(data);
        });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return Stream.value(Order.fromJSON({}));
  }
}

Future<Stream<Order>> getNearOrders(
  Address myAddress,
  Address areaAddress,
) async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> queryParams = {};
  User user = userRepo.currentUser.value;

  queryParams['api_token'] = user.apiToken;
  queryParams['limit'] = '6';
  queryParams['with'] =
      'driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  queryParams['search'] = 'driver.id:${user.id};delivery_address_id:null';
  queryParams['searchFields'] = 'driver.id:=;delivery_address_id:<>';
  queryParams['searchJoin'] = 'and';
  queryParams['orderBy'] = 'id';
  queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String, dynamic>))
        .expand((data) => (data as List))
        .map((data) {
          return Order.fromJSON(data);
        });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return Stream.value(Order.fromJSON({}));
  }
}

Future<Stream<Order>> getOrdersHistory() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> queryParams = {};
  User user = userRepo.currentUser.value;

  queryParams['api_token'] = user.apiToken;
  queryParams['with'] =
      'driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  queryParams['search'] =
      'driver.id:${user.id};order_status_id:5;delivery_address_id:null'; // Use 5 for delivered but add debug
  queryParams['searchFields'] =
      'driver.id:=;order_status_id:=;delivery_address_id:<>';
  queryParams['searchJoin'] = 'and';
  queryParams['orderBy'] = 'id';
  queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: queryParams);

  print('🔍 Order History API Request:');
  print('   - URL: $uri');
  print('   - Driver ID: ${user.id}');
  print('   - Looking for status ID: 5 (delivered)');

  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) {
          final result = Helper.getData(data as Map<String, dynamic>);
          print('📋 Order History Response: ${result}');
          print('   - Number of orders found: ${(result as List).length}');
          
          // Log details of first order for debugging
          if (result.isNotEmpty) {
            final firstOrder = result[0];
            print('   - First order status: ${firstOrder['order_status']}');
            print('   - First order ID: ${firstOrder['id']}');
            print('   - First order delivery address: ${firstOrder['delivery_address'] != null}');
          }
          
          return result;
        })
        .expand((data) => data)
        .map((data) {
          return Order.fromJSON(data);
        });
  } catch (e) {
    print('❌ Error in getOrdersHistory: $e');
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return Stream.value(Order.fromJSON({}));
  }
}

// Debug function to check all available order statuses
Future<List<OrderStatus>> debugOrderStatuses() async {
  print('🔍 Fetching all order statuses...');
  try {
    final Stream<OrderStatus> stream = await getOrderStatus();
    final statuses = await stream.toList();
    
    print('📋 Available Order Statuses:');
    for (var status in statuses) {
      print('   - ID: ${status.id}, Status: ${status.status}');
    }
    return statuses;
  } catch (e) {
    print('❌ Error fetching order statuses: $e');
  }
  return [];
}

// Function to get orders by multiple status IDs
Future<Stream<Order>> getOrdersByStatuses(List<String> statusIds) async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> queryParams = {};
  User user = userRepo.currentUser.value;

  queryParams['api_token'] = user.apiToken;
  queryParams['with'] =
      'driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  queryParams['search'] =
      'driver.id:${user.id};order_status_id:${statusIds.join(',')}';
  queryParams['searchFields'] = 'driver.id:=;order_status_id:in';
  queryParams['searchJoin'] = 'and';
  queryParams['orderBy'] = 'id';
  queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: queryParams);

  print('🔍 Multi-Status Orders Request:');
  print('   - URL: $uri');
  print('   - Status IDs: ${statusIds.join(', ')}');

  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) {
          final result = Helper.getData(data as Map<String, dynamic>);
          print('📋 Multi-Status Response: ${(result as List).length} orders found');
          return result;
        })
        .expand((data) => data)
        .map((data) {
          return Order.fromJSON(data);
        });
  } catch (e) {
    print('❌ Error in getOrdersByStatuses: $e');
    return Stream.value(Order.fromJSON({}));
  }
}

Future<Order> onTheWayOrder(Order order) async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return Order();
  }
  final String apiToken = 'api_token=${user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$apiToken';
  final client = http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.onTheWayMap()),
  );
  return Order.fromJSON(json.decode(response.body)['data']);
}

Future<Order> deliveredOrder(Order order) async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return Order();
  }
  final String apiToken = 'api_token=${user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$apiToken';
  final client = http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.deliveredMap()),
  );
  return Order.fromJSON(json.decode(response.body)['data']);
}

Future<Stream<Order>> getNewPendingOrders() async {
  Uri uri = Helper.getUri('api/orders'); // أو حسب وثائق الباك إند
  Map<String, dynamic> queryParams = {};
  User user = userRepo.currentUser.value;

  queryParams['api_token'] = user.apiToken;
  queryParams['with'] =
      'foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment;user';
  queryParams['search'] =
      'driver_id:null;order_status_id:1,2,3'; // طلبات غير معينة
  queryParams['searchFields'] = 'driver_id:=;order_status_id:in';
  queryParams['searchJoin'] = 'and';
  queryParams['orderBy'] = 'id';
  queryParams['sortedBy'] = 'desc';
  queryParams['limit'] = '20';

  uri = uri.replace(queryParameters: queryParams);

  try {
    final client = http.Client();
    final response = await client.get(uri);

    print('🔍 API Response Status: ${response.statusCode}');
    print('🔍 API Response Headers: ${response.headers}');
    print(
      '🔍 API Response Body (first 200 chars): ${response.body.substring(0, Math.min<int>(200, response.body.length))}',
    );

    // التحقق من Content-Type
    String? contentType = response.headers['content-type'];
    if (contentType != null && !contentType.contains('application/json')) {
      print('❌ Wrong Content-Type: $contentType');
      print('❌ Response is not JSON: ${response.body}');

      // إرجاع بيانات وهمية للاختبار
      return _getMockOrdersStream();
    }

    // التحقق من Status Code
    if (response.statusCode != 200) {
      print('❌ HTTP Error ${response.statusCode}: ${response.body}');
      return _getMockOrdersStream();
    }

    // التحقق من أن الـ response يبدأ بـ JSON
    String trimmedBody = response.body.trim();
    if (!trimmedBody.startsWith('{') && !trimmedBody.startsWith('[')) {
      print('❌ Response is not JSON format: $trimmedBody');
      return _getMockOrdersStream();
    }

    // محاولة parse الـ JSON
    Map<String, dynamic> jsonData = json.decode(response.body);
    List<dynamic> ordersData = Helper.getData(jsonData);

    return Stream.fromIterable(ordersData.map((data) => Order.fromJSON(data)));
  } catch (e) {
    print('❌ Error in getNewPendingOrders: $e');
    print('🔍 URI: $uri');

    // إرجاع بيانات وهمية في حالة الخطأ
    return _getMockOrdersStream();
  }
}

// دالة مساعدة للبيانات الوهمية
Stream<Order> _getMockOrdersStream() {
  print('🔄 Using mock data for testing...');

  List<Order> mockOrders = [
    Order.fromJSON({
      "id": "2047",
      "tax": 3.0,
      "delivery_fee": 5.0,
      "hint": "الطابق الثالث، الباب الأيمن - يرجى الرنين مرتين",
      "updated_at": DateTime.now().toIso8601String(),
      "order_status": {"id": "1", "status": "Order Received"},
      "user": {
        "id": "456",
        "name": "أحمد محمد العلي",
        "phone": "+970599123456",
        "email": "ahmed.ali@example.com",
      },
      "food_orders": [
        {
          "id": "1001",
          "quantity": 2,
          "price": 30.0,
          "food": {"id": "301", "name": "برجر دجاج مشوي", "price": 15.0},
        },
      ],
      "delivery_address": {
        "id": "789",
        "address": "شارع عمر المختار، مقابل البنك الأهلي، العمارة رقم 15",
        "latitude": 31.5017,
        "longitude": 34.4668,
      },
      "payment": {"method": "Cash on Delivery", "status": "Pending"},
    }),
  ];

  return Stream.fromIterable(mockOrders);
}

// Enhanced backend method with better debugging
Future<Order> acceptOrderWithStatus(String orderId, String statusId) async {
  try {
    Uri uri = Helper.getUri('api/manager/orders/$orderId');
    User user = userRepo.currentUser.value;
    
    // Check if user has valid token
    if (user.apiToken == null || user.apiToken!.isEmpty) {
      throw Exception('User not authenticated');
    }

    // Debug: Print the URL being called
    print('Calling API URL: $uri');
    print('Order ID: $orderId');
    print('Status ID: $statusId');
    print('API Token: ${user.apiToken?.substring(0, 10)}...'); // Only show first 10 chars for security

    Map<String, dynamic> queryParams = {};
    queryParams['api_token'] =  user.apiToken;
    queryParams['status'] = statusId;
    uri = uri.replace(queryParameters: queryParams);

    print('Final URL with params: $uri');

   final Dio dio = Dio();
    final response = await dio.put(
      uri.path,
      queryParameters: queryParams,
      
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body (first 500 chars): ${response.data.length > 500 ? response.data.substring(0, 1000) + "..." : response.data}');

    // Check if response is HTML (error page)
    if (response.data.trim().startsWith('<!DOCTYPE html') || 
        response.data.trim().startsWith('<html')) {
      throw Exception('Server returned HTML instead of JSON. Status: ${response.statusCode}. This usually means the API endpoint is incorrect or the server encountered an error.');
    }

    // Handle different response status codes
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final responseData = json.decode(response.data);
        if (responseData['data'] != null) {
          return Order.fromJSON(responseData['data']);
        } else {
          // Some APIs return the order directly without 'data' wrapper
          return Order.fromJSON(responseData);
        }
      } catch (jsonError) {
        throw Exception('Failed to parse JSON response: $jsonError. Response: ${response.data}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else if (response.statusCode == 404) {
      throw Exception('Order not found. Check if the order ID is correct: $orderId');
    } else if (response.statusCode == 422) {
      try {
        final errorData = json.decode(response.data);
        throw Exception('Validation error: ${errorData['message'] ?? 'Invalid data'}');
      } catch (jsonError) {
        throw Exception('Validation error (Status: ${response.statusCode}): ${response.data}');
      }
    } else {
      throw Exception('Server error: ${response.statusCode} - ${response.statusMessage}. Response: ${response.data}');
    }
  } catch (e) {
    print('Error updating order status: $e');
    rethrow;
  }
}
Future<Map<String, dynamic>> acceptOrderWithId(String orderId) async {
  Uri uri = Helper.getUri('api/driver/accept-order-by-driver');
  // api/driver/accept-order-by-driver
  User user = userRepo.currentUser.value;

  try {
    final client = http.Client();
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': user.apiToken,
        'driver_id': user.id,
        'order_id': orderId,
      }),
    );

    print('🔍 Accept Order Response Status: ${response.statusCode}');
    print(
      '🔍 Accept Order Response Body: ${response.body.substring(0, Math.min<int>(200, response.body.length))}',
    );

    // التحقق من Content-Type
    String? contentType = response.headers['content-type'];
    if (contentType != null && !contentType.contains('application/json')) {
      print('❌ Wrong Content-Type for accept: $contentType');

      // إذا كان الـ response HTML، يعني في مشكلة في الـ endpoint
      if (response.body.contains('<!DOCTYPE html>')) {
        return {
          'success': false,
          'message':
              'API endpoint not found. Response is HTML instead of JSON.',
          'debug_info': 'URL: $uri, Status: ${response.statusCode}',
        };
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      // محاولة parse الـ JSON
      try {
        Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Order accepted successfully',
          'data': responseData,
        };
      } catch (parseError) {
        print('❌ JSON Parse Error: $parseError');
        return {
          'success': false,
          'message': 'Invalid JSON response from server',
          'raw_response': response.body.substring(
            0,
            Math.min<int>(500, response.body.length),
          ),
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Failed to accept order: HTTP ${response.statusCode}',
        'error_body': response.body.substring(
          0,
          Math.min<int>(200, response.body.length),
        ),
      };
    }
  } catch (e) {
    print('❌ Error accepting order: $e');
    print('🔍 URI: $uri');
    return {
      'success': false,
      'message': 'Network error: $e',
      'debug_info': 'Check if the API endpoint exists and is accessible',
    };
  }
}

Future<Map<String, dynamic>> rejectOrderWithId(
  String orderId, {
  String? reason,
}) async {
  Uri uri = Helper.getUri('api/orders/$orderId/reject');
  User user = userRepo.currentUser.value;

  try {
    final client = http.Client();
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': user.apiToken,
        'driver_id': user.id,
        'reason': reason ?? 'Driver unavailable',
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Order rejected successfully'};
    } else {
      return {
        'success': false,
        'message': 'Failed to reject order: ${response.statusCode}',
      };
    }
  } catch (e) {
    print('Error rejecting order: $e');
    return {'success': false, 'message': 'Network error: $e'};
  }
}

Future<Map<String, dynamic>> updateDriverLocation(
  double latitude,
  double longitude,
) async {
  Uri uri = Helper.getUri('api/driver/location');
  User user = userRepo.currentUser.value;

  try {
    final client = http.Client();
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': user.apiToken,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Location updated successfully'};
    } else {
      return {'success': false, 'message': 'Failed to update location'};
    }
  } catch (e) {
    print('Error updating location: $e');
    return {'success': false, 'message': 'Network error: $e'};
  }
}

Future<Map<String, dynamic>> updateDriverAvailability(bool isAvailable) async {
  Uri uri = Helper.getUri('api/driver/availability');
  User user = userRepo.currentUser.value;

  try {
    final client = http.Client();
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': user.apiToken,
        'is_available': isAvailable,
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Availability updated successfully'};
    } else {
      return {'success': false, 'message': 'Failed to update availability'};
    }
  } catch (e) {
    print('Error updating availability: $e');
    return {'success': false, 'message': 'Network error: $e'};
  }
}

Future<OrderStatusHistory?> getOrderStatusHistory(String orderId) async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    print('❌ No API token available for order status history');
    // Return mock data for testing when no token
    return _getMockOrderStatusHistory(orderId);
  }

  try {
    final String apiToken = 'api_token=${user.apiToken}';
    final String url = '${GlobalConfiguration().getString('api_base_url')}orders/$orderId/status-history?$apiToken';
    
    print('🔄 Fetching order status history for order: $orderId');
    print('🔍 Status History URL: $url');
    
    final client = http.Client();
    final response = await client.get(Uri.parse(url));
    
    print('🔍 Status History Response Status: ${response.statusCode}');
    print('🔍 Status History Response Body (first 300 chars): ${response.body.length > 300 ? '${response.body.substring(0, 300)}...' : response.body}');
    
    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        print('✅ Order status history loaded successfully');
        return OrderStatusHistory.fromJson(jsonData);
      } catch (parseError) {
        print('❌ JSON Parse Error in status history: $parseError');
        // Fall back to mock data on parse error
        return _getMockOrderStatusHistory(orderId);
      }
    } else {
      print('❌ Failed to load order status history: ${response.statusCode}');
      print('Response: ${response.body}');
      // Fall back to mock data on error
      return _getMockOrderStatusHistory(orderId);
    }
  } catch (e) {
    print('❌ Error fetching order status history: $e');
    print(CustomTrace(StackTrace.current, message: e.toString()).toString());
    // Fall back to mock data on network error
    return _getMockOrderStatusHistory(orderId);
  }
}

// Helper function to provide mock order status history for testing
OrderStatusHistory _getMockOrderStatusHistory(String orderId) {
  print('🔄 Using mock order status history for testing...');
  
  final now = DateTime.now();
  final mockHistory = [
    {
      'id': '1',
      'status': '1',
      'status_name': 'تم استلام الطلب',
      'timestamp': now.subtract(Duration(hours: 2, minutes: 30)).toIso8601String(),
      'notes': 'تم استلام طلبكم بنجاح وجاري المراجعة',
      'updated_by': 'نظام إدارة الطلبات',
    },
    {
      'id': '2',
      'status': '2',
      'status_name': 'قيد التحضير',
      'timestamp': now.subtract(Duration(hours: 1, minutes: 45)).toIso8601String(),
      'notes': 'بدأ الطباخ في تحضير طلبكم',
      'updated_by': 'شيف المطعم - أحمد محمد',
    },
    {
      'id': '3',
      'status': '3',
      'status_name': 'جاهز للاستلام',
      'timestamp': now.subtract(Duration(hours: 1, minutes: 10)).toIso8601String(),
      'notes': 'طلبكم جاهز وننتظر وصول السائق',
      'updated_by': 'مدير المطعم - فاطمة أحمد',
    },
    {
      'id': '4',
      'status': '4',
      'status_name': 'في الطريق إليك',
      'timestamp': now.subtract(Duration(minutes: 25)).toIso8601String(),
      'notes': 'السائق خالد في طريقه إليكم - الوقت المتوقع للوصول 15 دقيقة',
      'updated_by': 'السائق - خالد عبدالله',
    },
  ];

  // Add delivered status if this is an older order (for testing)
  if (orderId == '2045' || orderId == '2046') {
    mockHistory.add({
      'id': '5',
      'status': '5',
      'status_name': 'تم التوصيل بنجاح',
      'timestamp': now.subtract(Duration(minutes: 5)).toIso8601String(),
      'notes': 'تم تسليم الطلب للعميل بنجاح - شكراً لاختياركم خدماتنا',
      'updated_by': 'السائق - خالد عبدالله',
    });
  }

  return OrderStatusHistory.fromJson({
    'order_id': orderId,
    'status_history': mockHistory,
  });
}

// **TEST FUNCTION: اختبار الاتصال مع الباك إند**
Future<Map<String, dynamic>> testConnection() async {
  print('🔄 Testing API connection...');

  // اختبار الـ base URL أولاً
  String baseUrl = GlobalConfiguration().getString('base_url');
  print('🔍 Base URL: $baseUrl');

  // فحص الـ User والـ Token
  User user = userRepo.currentUser.value;
  print('🔍 Current User Info:');
  print('   - User ID: ${user.id}');
  print('   - User Name: ${user.name}');
  print('   - User Email: ${user.email}');
  print('   - API Token Length: ${user.apiToken?.length ?? 0}');
  print(
    '   - API Token (first 20 chars): ${user.apiToken?.toString()}',
  );
  print('   - Token is null: ${user.apiToken == null}');
  print('   - Token is empty: ${user.apiToken?.isEmpty ?? true}');

  if (user.apiToken == null || user.apiToken!.isEmpty) {
    return {
      'success': false,
      'message': '🚨 NO API TOKEN FOUND!',
      'issue': 'mobile_app',
      'error': 'User is not logged in or token is missing',
      'suggestions': [
        '1. User needs to login again',
        '2. Check login functionality',
        '3. Verify token storage in SharedPreferences',
        '4. Check user authentication flow',
      ],
    };
  }

  Uri uri = Helper.getUri('api/orders');

  Map<String, dynamic> queryParams = {};
  queryParams['api_token'] = user.apiToken;
  queryParams['limit'] = '1';
  uri = uri.replace(queryParameters: queryParams);

  print('🔍 Full URL: $uri');

  try {
    final client = http.Client();

    // اختبار 1: بدون Token
    Uri uriWithoutToken = Helper.getUri('api/orders');
    print('🧪 Testing WITHOUT token...');
    final responseWithoutToken = await client.get(uriWithoutToken);
    print('🔍 Response WITHOUT token: ${responseWithoutToken.statusCode}');

    // اختبار 2: مع Token
    print('🧪 Testing WITH token...');
    final response = await client.get(uri);

    print('🔍 Response Status: ${response.statusCode}');
    print('🔍 Response Headers: ${response.headers}');
    print(
      '🔍 Response Body (first 500 chars): ${response.body.substring(0, Math.min<int>(500, response.body.length))}',
    );

    // فحص نوع المحتوى
    String? contentType = response.headers['content-type'];
    bool isJson =
        contentType != null && contentType.contains('application/json');
    bool isHtml =
        response.body.trim().startsWith('<!DOCTYPE html>') ||
        response.body.contains('<html>');

    Map<String, dynamic> result = {
      'success': response.statusCode == 200,
      'status_code': response.statusCode,
      'content_type': contentType,
      'is_json': isJson,
      'is_html': isHtml,
      'url': uri.toString(),
      'response_preview': response.body.substring(
        0,
        Math.min<int>(200, response.body.length),
      ),
      'token_length': user.apiToken?.length ?? 0,
      'user_id': user.id,
    };

    // تحليل نوع المشكلة
    if (response.statusCode == 401) {
      result['issue'] = 'authentication';
      result['message'] = '🚨 TOKEN AUTHENTICATION FAILED';
      result['suggestions'] = [
        '1. Token is expired or invalid',
        '2. User needs to login again',
        '3. Backend token validation issue',
        '4. Check token format requirements',
      ];
    } else if (response.statusCode == 404) {
      result['issue'] = 'endpoint';
      result['message'] = '🚨 API ENDPOINT NOT FOUND';
      result['suggestions'] = [
        '1. Wrong API URL in configurations.json',
        '2. Backend API routes not configured',
        '3. Server not running or deployed incorrectly',
        '4. Check with backend developer for correct URLs',
      ];
    } else if (isHtml) {
      result['issue'] = 'backend_config';
      result['message'] = '🚨 SERVER RETURNING HTML INSTEAD OF JSON';
      result['suggestions'] = [
        '1. API not properly configured on backend',
        '2. Laravel/Framework routing issue',
        '3. Middleware not working correctly',
        '4. Check backend logs for errors',
      ];
    } else if (response.statusCode == 500) {
      result['issue'] = 'backend_error';
      result['message'] = '🚨 BACKEND SERVER ERROR';
      result['suggestions'] = [
        '1. Database connection issue',
        '2. Backend code error',
        '3. Check backend server logs',
        '4. Contact backend developer',
      ];
    }

    if (response.statusCode == 200 && isJson) {
      try {
        result['parsed_data'] = json.decode(response.body);
        result['message'] = '✅ CONNECTION SUCCESSFUL - JSON RESPONSE RECEIVED';
        result['issue'] = 'none';
      } catch (e) {
        result['parse_error'] = e.toString();
        result['message'] = '⚠️ CONNECTION SUCCESSFUL BUT JSON PARSING FAILED';
        result['issue'] = 'json_format';
      }
    }

    return result;
  } catch (e) {
    print('❌ Network Error: $e');
    return {
      'success': false,
      'message': 'Network error: $e',
      'issue': 'network',
      'url': uri.toString(),
      'suggestions': [
        '1. Check internet connection',
        '2. Verify base URL in configurations.json',
        '3. Check if server is running and accessible',
        '4. Try ping/curl to test server connectivity',
      ],
    };
  }
}

Future<Stream<Order>> getOrder(String? orderId) async {
  if (orderId == null) {
    return Stream.value(Order.fromJSON({}));
  }
  
  Uri uri = Helper.getUri('api/orders/$orderId');
  User user = userRepo.currentUser.value;
  
  Map<String, dynamic> queryParams = {};
  queryParams['api_token'] = user.apiToken;
  queryParams['with'] = 'driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  
  uri = uri.replace(queryParameters: queryParams);
  
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String, dynamic>))
        .map((data) {
          return Order.fromJSON(data);
        });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    // Return mock order for testing
    return Stream.value(Order.fromJSON({
      "id": orderId,
      "tax": 3.0,
      "delivery_fee": 5.0,
      "hint": "Test order for tracking",
      "updated_at": DateTime.now().toIso8601String(),
      "order_status": {"id": "4", "status": "في الطريق"},
      "user": {
        "id": "456",
        "name": "أحمد محمد العلي",
        "phone": "+970599123456",
        "email": "ahmed.ali@example.com",
      },
      "food_orders": [
        {
          "id": "1001",
          "quantity": 2,
          "price": 30.0,
          "food": {"id": "301", "name": "برجر دجاج مشوي", "price": 15.0},
        },
      ],
      "delivery_address": {
        "id": "789",
        "address": "شارع عمر المختار، مقابل البنك الأهلي، العمارة رقم 15",
        "latitude": 31.5017,
        "longitude": 34.4668,
      },
      "payment": {"method": "Cash on Delivery", "status": "Pending"},
    }));
  }
}

Future<Stream<OrderStatus>> getOrderStatus() async {
  Uri uri = Helper.getUri('api/order_statuses');
  User user = userRepo.currentUser.value;
  
  Map<String, dynamic> queryParams = {};
  queryParams['api_token'] = user.apiToken;
  
  uri = uri.replace(queryParameters: queryParams);
  
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String, dynamic>))
        .expand((data) => (data as List))
        .map((data) {
          return OrderStatus.fromJSON(data);
        });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    // Return mock statuses for testing
    return Stream.fromIterable([
      OrderStatus.fromJSON({"id": "1", "status": "طلب جديد"}),
      OrderStatus.fromJSON({"id": "2", "status": "قيد التحضير"}),
      OrderStatus.fromJSON({"id": "3", "status": "جاهز للاستلام"}),
      OrderStatus.fromJSON({"id": "4", "status": "في الطريق"}),
      OrderStatus.fromJSON({"id": "5", "status": "تم التوصيل"}),
    ]);
  }
}
