import 'dart:convert';
import 'dart:io';

import 'package:deliveryboy/src/network/api_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
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
    '${GlobalConfiguration().getValue('base_url')}api/login', // Standard Laravel API
    '${GlobalConfiguration().getValue('api_base_url')}login', // Driver specific
    '${GlobalConfiguration().getValue('base_url')}/api/driver/login', // Explicit driver login
  ];

  final client = ApiClient().dio;

  for (String url in possibleUrls) {
    print('🔍 Trying login URL: $url');

    try {
      final response = await client.post(
        url,
        
        data:user.toMap(),
      );

      print('🔍 Login Response Status: ${response.statusCode}');
      print('🔍 Login Response Headers: ${response.headers}');
      print(
        '🔍 Login Response Body (first 200 chars): ${response.data.toString()}',
      );

      // فحص Content-Type
      String? contentType = response.headers.map['content-type']?.first;
      bool isJson =
          contentType != null && contentType.contains('application/json');
      bool isHtml =
          response.data.toString().trim().startsWith('<!DOCTYPE html>') ||
          response.data.toString().contains('<html>') ||
          response.data.toString().contains('<link rel=');

      if (isHtml) {
        print('❌ Login URL $url returned HTML instead of JSON');
        continue; // جرب الـ URL التالي
      }

      if (response.statusCode == 200 && isJson) {
        print('✅ Login successful with URL: $url');

        // التحقق من أن الـ JSON valid
        try {
          Map<dynamic, dynamic> responseData = response.data;

          if (responseData['data'] != null) {
            setCurrentUser(json.encode(responseData));
            currentUser.value = UserModel.User.fromJSON(responseData['data']);
            return currentUser.value;
          } else {
            print('❌ Login response missing "data" field');
            throw Exception('Invalid login response format');
          }
        } catch (jsonError) {
          print('❌ JSON parsing error: $jsonError');
          print('❌ Response body: ${response.data}');
          throw Exception('Invalid JSON response from login API');
        }
      } else if (response.statusCode == 401) {
        print('❌ Login failed: Invalid credentials');
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 422) {
        print('❌ Login failed: Validation error');
        try {
          Map<String, dynamic> errorData = response.data;
          String errorMessage = errorData['message'] ?? 'Validation failed';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Validation failed');
        }
      } else {
        print('❌ Login failed with status ${response.statusCode}');
        print('❌ Response: ${response.data}');
        continue; // جرب الـ URL التالي
      }
    } catch (e) {
      print('❌ Error with login URL $url: $e');
      if (url == possibleUrls.last) {
        // إذا كان آخر URL، ارمي الخطأ
        rethrow;
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

Future<void> updateDriverLocation(double lat, double lng, int orderId) async {
  if (currentUser.value.id == null) {
    print('❌ updateDriverLocation: User not authenticated');
    return;
  }
  
  print('📍 Updating driver location: lat=$lat, lng=$lng, orderId=$orderId');
  
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
        'order_id': orderId,
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
  final String apiToken = 'api_token=${currentUser.value.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}${currentUser.value.id}/update_availability?$apiToken';
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
      '${GlobalConfiguration().getValue('base_url')}api/uploads';
  var request = http.MultipartRequest("POST", Uri.parse(url));
  // request.fields['file'] = body.file.toString();
  request.fields['uuid'] = body.uuid!;
  request.fields['field'] = body.field!;
  request.files.add(await http.MultipartFile.fromPath('file', body.file!.path));

  return await request.send();
}

Future<UserModel.User> register(UserModel.User user) async {
  try {
    print('🚀 Starting registration process...');
    
    // Try multiple possible registration endpoints
    List<String> possibleUrls = [
      '${GlobalConfiguration().getValue('base_url')}/api/driver/register',
      '${GlobalConfiguration().getValue('api_base_url')}driver/register',
      'http://carrytechnologies.co/api/driver/register',
    ];

    Exception? lastException;
    
    for (String url in possibleUrls) {
      print('🔍 Trying registration URL: $url');
      
      try {
        // Create multipart request
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(url),
        );

        // Set name from firstName and lastName if not set
        String fullName = user.name ?? '';
        if (fullName.isEmpty && (user.firstName?.isNotEmpty == true || user.lastName?.isNotEmpty == true)) {
          fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
        }
        
        // Clean and validate data before sending
        String cleanEmail = (user.email ?? '').trim();
        String cleanFirstName = (user.firstName ?? '').trim();
        String cleanLastName = (user.lastName ?? '').trim();
        String cleanPhone = (user.phone ?? '').trim();
        String cleanDeliveryCity = (user.deliveryCity ?? '').trim();
        
        // Add text fields - Only send basic fields like Postman
        Map<String, String> fields = {
          'name': fullName,
          'email': cleanEmail,
          'password': user.password ?? '',
          'password_confirmation': user.passwordConfirmation ?? '',
        };
        
        // Print user data for debugging
        print('🔍 User data to be sent:');
        fields.forEach((key, value) {
          print('  $key: $value');
        });
        
        // Print raw user object for debugging
        print('🔍 Raw user object:');
        print('  user.name: ${user.name}');
        print('  user.email: ${user.email}');
        print('  user.password: ${user.password}');
        print('  user.firstName: ${user.firstName}');
        print('  user.lastName: ${user.lastName}');
        print('  user.phone: ${user.phone}');
        print('  user.deliveryCity: ${user.deliveryCity}');
        print('  user.vehicleType: ${user.vehicleType}');
        print('  user.languagesSpoken: ${user.languagesSpoken}');
        print('  user.dateOfBirth: ${user.dateOfBirth}');
        print('  user.referralCode: ${user.referralCode}');
        print('  user.bankName: ${user.bankName}');
        print('  user.accountNumber: ${user.accountNumber}');
        print('  user.branchNumber: ${user.branchNumber}');
        
        request.fields.addAll(fields);

        // Temporarily skip file uploads to match Postman request
        print('🔍 Skipping file uploads for now to match Postman format');

        print('📤 Sending registration request to: $url');
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            Map<String, dynamic> responseData = json.decode(response.body);
            
            if (responseData['data'] != null) {
              setCurrentUser(response.body);
              currentUser.value = UserModel.User.fromJSON(responseData['data']);
              print('✅ Registration successful with URL: $url');
              return currentUser.value;
            } else {
              print('❌ Response missing data field');
              throw Exception('Invalid response format');
            }
          } catch (e) {
            print('❌ JSON parsing error: $e');
            throw Exception('Invalid response format');
          }
        } else if (response.statusCode == 401) {
          print('❌ Registration failed with 401 Unauthorized');
          print('❌ This might be due to:');
          print('   - Invalid API endpoint');
          print('   - Missing authentication headers');
          print('   - Server configuration issue');
          print('   - Invalid data format');
          
          try {
            Map<String, dynamic> errorData = json.decode(response.body);
            String errorMessage = errorData['message'] ?? 'Unauthorized - Please check API configuration';
            print('❌ Server error message: $errorMessage');
            
            // No need for retry logic since we're sending minimal fields like Postman
            
            lastException = Exception(errorMessage);
          } catch (e) {
            lastException = Exception('Registration failed with 401 Unauthorized');
          }
          
          // Continue to next URL
          continue;
        } else {
          print('❌ Registration failed with status: ${response.statusCode}');
          print('❌ Error response: ${response.body}');
          
          try {
            Map<String, dynamic> errorData = json.decode(response.body);
            String errorMessage = errorData['message'] ?? 'Registration failed';
            lastException = Exception(errorMessage);
          } catch (e) {
            lastException = Exception('Registration failed with status ${response.statusCode}');
          }
          
          // Continue to next URL
          continue;
        }
      } catch (e) {
        print('❌ Error with registration URL $url: $e');
        lastException = Exception('Error with URL $url: $e');
        
        if (url == possibleUrls.last) {
          // If this is the last URL, throw the exception
          break;
        }
        // Otherwise, continue to next URL
        continue;
      }
    }

    // If we reach here, all URLs failed
    if (lastException != null) {
      throw lastException;
    } else {
      throw Exception('Registration failed: All endpoints failed. Please contact backend developer.');
    }
  } catch (e) {
    print('❌ Registration error: $e');
    throw Exception('Registration failed: $e');
  }
}

String? _getDocumentPath(UserModel.User user, String field) {
  switch (field) {
    case 'drivingLicense':
      return user.drivingLicense;
    case 'businessLicense':
      return user.businessLicense;
    case 'accountingCertificate':
      return user.accountingCertificate;
    case 'taxCertificate':
      return user.taxCertificate;
    case 'accountManagementCertificate':
      return user.accountManagementCertificate;
    case 'bankAccountDetails':
      return user.bankAccountDetails;
    default:
      return null;
  }
}

Future<UserModel.User> getCurrentUserAsync() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
    currentUser.value = UserModel.User.fromJSON(
      json.decode(prefs.get('current_user') as String),
    );
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  return currentUser.value;
}

Future<bool> resetPassword(UserModel.User user) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}send_reset_link_email';
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
      '🔍 setCurrentUser called with: $jsonString',
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
      // Check if user is active before saving
      final userData = parsedJson['data'];
      final isActive = userData['is_active'] ?? 1;
      
      // Save user data regardless of isActive status for splash screen check
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(parsedJson['data']));
      print('✅ User data saved to SharedPreferences (isActive: $isActive)');
      
      if (isActive == 0) {
        print('⚠️ User is inactive (isActive: $isActive), but data saved for splash screen check');
      }
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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('credit_card', json.encode(creditCard.toMap()));
}

Future<UserModel.User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
    currentUser.value = UserModel.User.fromJSON(
      json.decode(prefs.get('current_user') as String),
    );
    currentUser.value.auth = true;
    
    // Check if locally saved user is inactive
    if (currentUser.value.isActive == 0) {
      print('🔍 Locally saved user is inactive, clearing data immediately');
      // Clear data immediately for inactive users
      await prefs.remove('current_user');
      currentUser.value = UserModel.User();
      currentUser.value.auth = false;
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      currentUser.notifyListeners();
      return currentUser.value;
    }
    
    // Check if user is active from server
    try {
      final response = await http.get(
        Uri.parse('${GlobalConfiguration().getValue('api_base_url')}users/profile?api_token=${currentUser.value.apiToken}'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body)['data'];
        final serverIsActive = userData['is_active'] ?? 1;
        
        print('🔍 Server isActive: $serverIsActive, Local isActive: ${currentUser.value.isActive}');
        
        if (serverIsActive == 0) {
          print('🔍 User is inactive on server, clearing user data');
          // Clear user data if inactive
          await prefs.remove('current_user');
          currentUser.value = UserModel.User();
          currentUser.value.auth = false;
          // Don't save inactive user data
          return currentUser.value;
        } else {
          // Update local data with server data
          currentUser.value.isActive = serverIsActive;
          await prefs.setString('current_user', json.encode(currentUser.value.toMap()));
        }
      }
    } catch (e) {
      print('🔍 Error checking user status from server: $e');
      // If we can't check from server, use local data
      if (currentUser.value.isActive == 0) {
        print('🔍 User is inactive locally, clearing user data');
        await prefs.remove('current_user');
        currentUser.value = UserModel.User();
        currentUser.value.auth = false;
      }
    }
  } else {
    currentUser.value.auth = false;
  }
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<CreditCard> getCreditCard() async {
  CreditCard creditCard = CreditCard();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('credit_card')) {
    creditCard = CreditCard.fromJSON(
      json.decode(prefs.get('credit_card') as String),
    );
  }
  return creditCard;
}

Future<UserModel.User> update(UserModel.User user) async {
  final String apiToken = 'api_token=${currentUser.value.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}users/${currentUser.value.id}?$apiToken';
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
  UserModel.User user = currentUser.value;
  final String apiToken = 'api_token=${user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$apiToken&search=user_id:${user.id}&searchFields=user_id:=&orderBy=is_default&sortedBy=desc';
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
  UserModel.User user = userRepo.currentUser.value;
  final String apiToken = 'api_token=${user.apiToken}';
  address.userId = user.id;
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$apiToken';
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
  UserModel.User user = userRepo.currentUser.value;
  final String apiToken = 'api_token=${user.apiToken}';
  address.userId = user.id;
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$apiToken';
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
  UserModel.User user = userRepo.currentUser.value;
  final String apiToken = 'api_token=${user.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$apiToken';
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

Future<bool> updateUserActiveStatus(int isActive) async {
  if (currentUser.value.id == null) {
    print('❌ updateUserActiveStatus: User not authenticated');
    return false;
  }
  
  try {
    final response = await http.post(
      Uri.parse('${GlobalConfiguration().getValue('api_base_url')}users/${currentUser.value.id}/update-active-status'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'api_token': currentUser.value.apiToken,
        'is_active': isActive,
      }),
    );

    print('🔍 Update Active Status Response Status: ${response.statusCode}');
    print('🔍 Update Active Status Response: ${response.body}');

    if (response.statusCode == 200) {
      // Update local user data
      currentUser.value.isActive = isActive;
      print('✅ User active status updated successfully');
      return true;
    } else {
      print('❌ Failed to update user active status: ${response.statusCode}');
      print('❌ Response: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Error updating user active status: $e');
    return false;
  }
}