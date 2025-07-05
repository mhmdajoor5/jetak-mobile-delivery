import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Order>> getOrders() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  final String orderStatusId = "5"; // for delivered status
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['with'] =
      'driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  _queryParams['search'] =
      'driver.id:${_user.id};order_status_id:$orderStatusId;delivery_address_id:null';
  _queryParams['searchFields'] =
      'driver.id:=;order_status_id:<>;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
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
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getNearOrders(
  Address myAddress,
  Address areaAddress,
) async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['limit'] = '6';
  _queryParams['with'] =
      'driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  _queryParams['search'] = 'driver.id:${_user.id};delivery_address_id:null';
  _queryParams['searchFields'] = 'driver.id:=;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
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
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getOrdersHistory() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  final String orderStatusId = "5"; // for delivered status
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['with'] =
      'driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  _queryParams['search'] =
      'driver.id:${_user.id};order_status_id:$orderStatusId;delivery_address_id:null';
  _queryParams['searchFields'] =
      'driver.id:=;order_status_id:=;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
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
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getOrder(orderId) async {
  // **MOCK DATA للتجربة - احذف هذا عند ربط الباك إند**
  print('🔄 Loading order details for ID: $orderId');

  // بيانات وهمية حسب الـ order ID
  Map<String, dynamic> orderData = {};

  if (orderId == '2047') {
    orderData = {
      "id": "2047",
      "tax": 3.0,
      "delivery_fee": 5.0,
      "hint": "الطابق الثالث، الباب الأيمن - يرجى الرنين مرتين",
      "updated_at": DateTime.now().toIso8601String(),
      "order_status": {"id": "3", "status": "Ready for Pickup"},
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
        {
          "id": "1002",
          "quantity": 1,
          "price": 8.0,
          "food": {"id": "302", "name": "بطاطس مقلية كبيرة", "price": 8.0},
        },
        {
          "id": "1003",
          "quantity": 2,
          "price": 6.0,
          "food": {"id": "303", "name": "مشروب غازي", "price": 3.0},
        },
      ],
      "delivery_address": {
        "id": "789",
        "address":
            "شارع عمر المختار، مقابل البنك الأهلي، العمارة رقم 15، الطابق الثالث",
        "latitude": 31.5017,
        "longitude": 34.4668,
      },
      "payment": {"method": "Cash on Delivery", "status": "Pending"},
    };
  } else if (orderId == '2048') {
    orderData = {
      "id": "2048",
      "tax": 4.5,
      "delivery_fee": 7.0,
      "hint": "البناية الزرقاء بجانب الصيدلية، شقة 4ب",
      "updated_at":
          DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
      "order_status": {"id": "3", "status": "Ready for Pickup"},
      "user": {
        "id": "457",
        "name": "فاطمة سالم قاسم",
        "phone": "+970598987654",
        "email": "fatima.salem@example.com",
      },
      "food_orders": [
        {
          "id": "1004",
          "quantity": 1,
          "price": 35.0,
          "food": {"id": "304", "name": "بيتزا مارجريتا كبيرة", "price": 35.0},
        },
        {
          "id": "1005",
          "quantity": 1,
          "price": 15.0,
          "food": {"id": "305", "name": "سلطة يونانية", "price": 15.0},
        },
      ],
      "delivery_address": {
        "id": "790",
        "address": "حي الشيخ رضوان، شارع صلاح الدين، مجمع النور، شقة 4ب",
        "latitude": 31.5203,
        "longitude": 34.4776,
      },
      "payment": {"method": "Credit Card", "status": "Paid"},
    };
  } else if (orderId == '2049') {
    orderData = {
      "id": "2049",
      "tax": 2.5,
      "delivery_fee": 4.0,
      "hint": "",
      "updated_at":
          DateTime.now().subtract(Duration(minutes: 2)).toIso8601String(),
      "order_status": {"id": "3", "status": "Ready for Pickup"},
      "user": {
        "id": "458",
        "name": "محمد عبدالله حسن",
        "phone": "+970567891234",
        "email": "mohammed.hassan@example.com",
      },
      "food_orders": [
        {
          "id": "1006",
          "quantity": 3,
          "price": 24.0,
          "food": {"id": "306", "name": "شاورما لحم", "price": 8.0},
        },
        {
          "id": "1007",
          "quantity": 1,
          "price": 12.0,
          "food": {"id": "307", "name": "حمص بالطحينة", "price": 12.0},
        },
      ],
      "delivery_address": {
        "id": "791",
        "address":
            "شارع الجلاء، بجانب مسجد النور، العمارة رقم 12، الطابق الأول",
        "latitude": 31.4969,
        "longitude": 34.4532,
      },
      "payment": {"method": "PayPal", "status": "Paid"},
    };
  } else {
    // Default mock order للـ IDs الأخرى
    orderData = {
      "id": orderId.toString(),
      "tax": 0.0,
      "delivery_fee": 0.0,
      "hint": "",
      "updated_at": DateTime.now().toIso8601String(),
      "order_status": {"id": "1", "status": "Pending"},
      "user": {
        "id": "999",
        "name": "Unknown Customer",
        "phone": "",
        "email": "",
      },
      "food_orders": [],
      "delivery_address": {"id": "999", "address": "Address not available"},
      "payment": {"method": "Unknown", "status": "Unknown"},
    };
  }

  await Future.delayed(Duration(milliseconds: 500)); // محاكاة تأخير الشبكة
  return Stream.value(Order.fromJSON(orderData));

  // **الكود الأصلي - فعّله عند ربط الباك إند**
  /*
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(new Order());
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orders/$orderId?${_apiToken}with=user;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getObjectData(data as Map<String,dynamic>))
      .map((data) {
    return Order.fromJSON(data);
  });
  */
}

Future<Stream<Order>> getRecentOrders() async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['limit'] = '4';
  _queryParams['with'] =
      'driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment';
  _queryParams['search'] = 'driver.id:${_user.id};delivery_address_id:null';
  _queryParams['searchFields'] = 'driver.id:=;delivery_address_id:<>';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders?${_apiToken}with=driver;foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
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
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<OrderStatus>> getOrderStatus() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(new OrderStatus());
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}order_statuses?$_apiToken';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String, dynamic>))
      .expand((data) => (data as List))
      .map((data) {
        return OrderStatus.fromJSON(data);
      });
}

Future<Order> onTheWayOrder(Order order) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Order();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.onTheWayMap()),
  );
  return Order.fromJSON(json.decode(response.body)['data']);
}

Future<Order> deliveredOrder(Order order) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Order();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.deliveredMap()),
  );
  return Order.fromJSON(json.decode(response.body)['data']);
}

Future<Stream<Order>> getNewPendingOrders() async {
  User _user = userRepo.currentUser.value;
  Uri uri = Helper.getUri(
    'api/driver/driver-candidate-orders/${_user.id}',
  ); // أو حسب وثائق الباك إند
  // https://carrytechnologies.co/api/driver/driver-candidate-orders/{driver_id}
  Map<String, dynamic> _queryParams = {};

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['with'] =
      'foodOrders;foodOrders.food;foodOrders.extras;orderStatus;deliveryAddress;payment;user';
  _queryParams['search'] =
      'driver_id:null;order_status_id:1,2,3'; // طلبات غير معينة
  _queryParams['searchFields'] = 'driver_id:=;order_status_id:in';
  _queryParams['searchJoin'] = 'and';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  _queryParams['limit'] = '20';

  uri = uri.replace(queryParameters: _queryParams);

  try {
    final client = http.Client();
    final response = await client.post(uri);

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
    List<dynamic> ordersData = jsonData['orders'];

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

Future<Map<String, dynamic>> acceptOrderWithId(String orderId) async {
  Uri uri = Helper.getUri('api/driver/accept-order-by-driver');
  // api/driver/accept-order-by-driver
  User _user = userRepo.currentUser.value;

  try {
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': _user.apiToken,
        'driver_id': _user.id,
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
  User _user = userRepo.currentUser.value;

  try {
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': _user.apiToken,
        'driver_id': _user.id,
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
  User _user = userRepo.currentUser.value;

  try {
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': _user.apiToken,
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
  User _user = userRepo.currentUser.value;

  try {
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': _user.apiToken,
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

// **TEST FUNCTION: اختبار الاتصال مع الباك إند**
Future<Map<String, dynamic>> testConnection() async {
  print('🔄 Testing API connection...');

  // اختبار الـ base URL أولاً
  String baseUrl = GlobalConfiguration().getString('base_url');
  print('🔍 Base URL: $baseUrl');

  // فحص الـ User والـ Token
  User _user = userRepo.currentUser.value;
  print('🔍 Current User Info:');
  print('   - User ID: ${_user.id}');
  print('   - User Name: ${_user.name}');
  print('   - User Email: ${_user.email}');
  print('   - API Token Length: ${_user.apiToken?.length ?? 0}');
  print(
    '   - API Token (first 20 chars): ${_user.apiToken?.substring(0, Math.min<int>(20, _user.apiToken?.length ?? 0))}...',
  );
  print('   - Token is null: ${_user.apiToken == null}');
  print('   - Token is empty: ${_user.apiToken?.isEmpty ?? true}');

  if (_user.apiToken == null || _user.apiToken!.isEmpty) {
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

  Map<String, dynamic> _queryParams = {};
  _queryParams['api_token'] = _user.apiToken;
  _queryParams['limit'] = '1';
  uri = uri.replace(queryParameters: _queryParams);

  print('🔍 Full URL: $uri');

  try {
    final client = new http.Client();

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
      'token_length': _user.apiToken?.length ?? 0,
      'user_id': _user.id,
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
