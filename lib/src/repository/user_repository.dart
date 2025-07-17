import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/credit_card.dart';
import '../models/document.dart';
import '../models/user.dart' as UserModel;
import '../repository/user_repository.dart' as userRepo;

ValueNotifier<UserModel.User> currentUser = ValueNotifier(UserModel.User());

final HttpWithMiddleware httpWithMiddleware = HttpWithMiddleware.build(
  requestTimeout: Duration(seconds: 30),
  middlewares: [HttpLogger(logLevel: LogLevel.BODY)],
);

Future<UserModel.User> login(UserModel.User user) async {
  // تجربة URLs مختلفة للـ login
  List<String> possibleUrls = [
    '${GlobalConfiguration().getString('base_url')}api/login', // Standard Laravel API
    '${GlobalConfiguration().getString('api_base_url')}login', // Driver specific
    '${GlobalConfiguration().getString('base_url')}api/driver/login', // Explicit driver login
  ];

  final client = http.Client();

  for (String url in possibleUrls) {
    print('🔍 Trying login URL: $url');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(user.toMap()),
      );

      print('🔍 Login Response Status: ${response.statusCode}');
      print('🔍 Login Response Headers: ${response.headers}');
      print(
        '🔍 Login Response Body (first 200 chars): ${response.body.substring(0, Math.min<int>(200, response.body.length))}',
      );

      // فحص Content-Type
      String? contentType = response.headers['content-type'];
      bool isJson =
          contentType != null && contentType.contains('application/json');
      bool isHtml =
          response.body.trim().startsWith('<!DOCTYPE html>') ||
          response.body.contains('<html>') ||
          response.body.contains('<link rel=');

      if (isHtml) {
        print('❌ Login URL $url returned HTML instead of JSON');
        continue; // جرب الـ URL التالي
      }

      if (response.statusCode == 200 && isJson) {
        print('✅ Login successful with URL: $url');

        // التحقق من أن الـ JSON valid
        try {
          Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData['data'] != null) {
            setCurrentUser(response.body);
            currentUser.value = UserModel.User.fromJSON(responseData['data']);
            return currentUser.value;
          } else {
            print('❌ Login response missing "data" field');
            throw Exception('Invalid login response format');
          }
        } catch (jsonError) {
          print('❌ JSON parsing error: $jsonError');
          print('❌ Response body: ${response.body}');
          throw Exception('Invalid JSON response from login API');
        }
      } else if (response.statusCode == 401) {
        print('❌ Login failed: Invalid credentials');
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 422) {
        print('❌ Login failed: Validation error');
        try {
          Map<String, dynamic> errorData = json.decode(response.body);
          String errorMessage = errorData['message'] ?? 'Validation failed';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Validation failed');
        }
      } else {
        print('❌ Login failed with status ${response.statusCode}');
        print('❌ Response: ${response.body}');
        continue; // جرب الـ URL التالي
      }
    } catch (e) {
      print('❌ Error with login URL $url: $e');
      if (url == possibleUrls.last) {
        // إذا كان آخر URL، ارمي الخطأ
        throw e;
      }
      // وإلا، جرب الـ URL التالي
      continue;
    }
  }

  // إذا وصلنا هنا، يعني كل الـ URLs فشلت
  throw Exception(
    'Login failed: All login endpoints returned HTML or failed. Please contact backend developer to configure login API correctly.',
  );
}

Future<void> updateDriverLocation(double lat, double lng) async {
  if (currentUser.value.id == null) {
    print('❌ updateDriverLocation: User not authenticated');
    return;
  }
  
  print('📍 Updating driver location: lat=$lat, lng=$lng');
  
  try {
    final response = await http.post(
      Uri.parse('https://carrytechnologies.co/api/driver/orders/update-driver-location'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': currentUser.value.apiToken,
        'driver_id': currentUser.value.id,
        'latitude': lat,
        'longitude': lng,
      }),
  );

    print('📍 Location Update Response Status: ${response.statusCode}');
    print('📍 Location Update Response: ${response.body}');

  if (response.statusCode == 200) {
      print('✅ Driver location updated successfully');
  } else {
      print('❌ Failed to update driver location: ${response.statusCode}');
      print('❌ Response: ${response.body}');
  }
  } catch (e) {
    print('❌ Error updating driver location: $e');
  }
}

Future<void> updateDriverAvailability(bool value) async {
  if (currentUser.value.id == null) {
    return;
  }
  final String _apiToken = 'api_token=${currentUser.value.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}${currentUser.value.id}/update_availability?$_apiToken';
  final client = http.Client();
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({"available": value}),
  );
  if (response.statusCode == 200) {
    // setCurrentUser(response.body);
    // currentUser.value = UserModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw Exception(response.body);
  }
  // return currentUser.value;
}

Future<dynamic> upload(Document body) async {
  HttpWithMiddleware httpWithMiddleware = HttpWithMiddleware.build(
    requestTimeout: Duration(seconds: 240),
    middlewares: [
      // HttpLogger(logLevel: LogLevel.BODY),
    ],
  );
  final String url =
      '${GlobalConfiguration().getString('base_url')}api/uploads';
  var request = http.MultipartRequest("POST", Uri.parse(url));
  // request.fields['file'] = body.file.toString();
  request.fields['uuid'] = body.uuid!;
  request.fields['field'] = body.field!;
  request.files.add(await http.MultipartFile.fromPath('file', body.file!.path));

  return await request.send();
}

Future<UserModel.User> register(UserModel.User user) async {
  HttpWithMiddleware httpWithMiddleware = HttpWithMiddleware.build(
    requestTimeout: Duration(seconds: 30),
    middlewares: [HttpLogger(logLevel: LogLevel.BODY)],
  );
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}register';
  final client = http.Client();
  final response = await httpWithMiddleware.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value = UserModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw Exception(response.body);
  }
  return currentUser.value;
}

Future<UserModel.User> getCurrentUserAsync() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
    currentUser.value = UserModel.User.fromJSON(
      json.decode(await prefs.get('current_user') as String),
    );
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  return currentUser.value;
}

Future<bool> resetPassword(UserModel.User user) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}send_reset_link_email';
  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw Exception(response.body);
  }
}

Future<void> logout() async {
  currentUser.value = UserModel.User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
}

void setCurrentUser(jsonString) async {
  try {
    print(
      '🔍 setCurrentUser called with: ${jsonString.substring(0, Math.min<int>(200, jsonString.length))}...',
    );

    // التحقق من أن jsonString ليس HTML
    if (jsonString.toString().trim().startsWith('<!DOCTYPE html>') ||
        jsonString.toString().contains('<html>') ||
        jsonString.toString().contains('<link rel=')) {
      print('❌ setCurrentUser received HTML instead of JSON');
      throw Exception(
        'Server returned HTML instead of JSON - API endpoint not found',
      );
    }

    // محاولة parse الـ JSON
    Map<String, dynamic> parsedJson = json.decode(jsonString);

    if (parsedJson['data'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(parsedJson['data']));
      print('✅ User data saved to SharedPreferences');
    } else {
      print('❌ Missing "data" field in login response');
      throw Exception('Invalid response format: missing "data" field');
    }
  } catch (e) {
    print('❌ setCurrentUser error: $e');
    print('❌ Received data: $jsonString');

    if (e is FormatException) {
      throw Exception('Invalid JSON format received from server');
    } else {
      throw Exception('Error saving user data: $e');
    }
  }
}

Future<void> setCreditCard(CreditCard creditCard) async {
  if (creditCard != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('credit_card', json.encode(creditCard.toMap()));
  }
}

Future<UserModel.User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
    currentUser.value = UserModel.User.fromJSON(
      json.decode(await prefs.get('current_user') as String),
    );
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<CreditCard> getCreditCard() async {
  CreditCard _creditCard = CreditCard();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('credit_card')) {
    _creditCard = CreditCard.fromJSON(
      json.decode(await prefs.get('credit_card') as String),
    );
  }
  return _creditCard;
}

Future<UserModel.User> update(UserModel.User user) async {
  final String _apiToken = 'api_token=${currentUser.value.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}users/${currentUser.value.id}?$_apiToken';
  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  setCurrentUser(response.body);
  currentUser.value = UserModel.User.fromJSON(json.decode(response.body)['data']);
  return currentUser.value;
}

Future<Stream<Address>> getAddresses() async {
  UserModel.User _user = currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}delivery_addresses?$_apiToken&search=user_id:${_user.id}&searchFields=user_id:=&orderBy=is_default&sortedBy=desc';
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data as Map<String, dynamic>))
        .expand((data) => (data as List))
        .map((data) {
          return Address.fromJSON(data);
        });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return Stream.value(Address.fromJSON({}));
  }
}

Future<Address> addAddress(Address address) async {
  UserModel.User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}delivery_addresses?$_apiToken';
  final client = http.Client();
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(address.toMap()),
    );
    return Address.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return Address.fromJSON({});
  }
}

Future<Address> updateAddress(Address address) async {
  UserModel.User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = http.Client();
  try {
    final response = await client.put(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(address.toMap()),
    );
    return Address.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return Address.fromJSON({});
  }
}

Future<Address> removeDeliveryAddress(Address address) async {
  UserModel.User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = http.Client();
  try {
    final response = await client.delete(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return Address.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return Address.fromJSON({});
  }
}
