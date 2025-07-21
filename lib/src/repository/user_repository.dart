import 'dart:convert';

import 'package:deliveryboy/src/constants/const/api_endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../models/address.dart';
import '../models/credit_card.dart';
import '../models/document.dart';
import '../models/user.dart' as UserModel;

/// Global current user notifier
ValueNotifier<UserModel.User> currentUser = ValueNotifier(UserModel.User());

/// User Repository class that handles all user-related API operations
class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  final ApiClient _apiClient = ApiClient();


  /// Login user with email and password
  Future<UserModel.User> login(UserModel.User user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: user.toMap(),
      );

      if (response.data == null) {
        throw ApiException('Empty response from server', response.statusCode ?? 0);
      }

      final userData = response.data['data'] ?? response.data;
      if (userData == null) {
        throw ApiException('Invalid login response format', response.statusCode ?? 0);
      }

      // Save user data
      await _saveUserData(response.data);
      currentUser.value = UserModel.User.fromJSON(userData);
      
      // Save auth tokens if available
      if (userData['api_token'] != null) {
        await _apiClient.setAuthToken(
          userData['api_token'], 
          userData['refresh_token'] ?? userData['api_token']
        );
      }

      debugPrint('✅ User logged in successfully: ${currentUser.value.email}');
      return currentUser.value;
    } on DioException catch (e) {
      debugPrint('❌ Login failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected login error: $e');
      throw ApiException('Login failed: $e', 0);
    }
  }

  /// Register a new user
  Future<UserModel.User> register(UserModel.User user) async {
    try {
      debugPrint('👤 Registering user: ${user.email}');
      
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: user.toMap(),
      );

      if (response.data == null) {
        throw ApiException('Empty response from server', response.statusCode ?? 0);
      }

      // Save user data
      await _saveUserData(response.data);
      
      final userData = response.data['data'] ?? response.data;
      currentUser.value = UserModel.User.fromJSON(userData);

      // Save auth tokens if available
      if (userData['api_token'] != null) {
        await _apiClient.setAuthToken(
          userData['api_token'], 
          userData['refresh_token'] ?? userData['api_token']
        );
      }

      debugPrint('✅ User registered successfully: ${currentUser.value.email}');
      return currentUser.value;
    } on DioException catch (e) {
      debugPrint('❌ Registration failed: ${e.message}');
      if (e.response?.data != null) {
        final errorMessage = _extractErrorMessage(e.response!.data);
        throw ApiException(errorMessage, e.response!.statusCode ?? 0);
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected registration error: $e');
      throw ApiException('Registration failed: $e', 0);
    }
  }

  /// Reset password by sending reset link to email
  Future<bool> resetPassword(UserModel.User user) async {
    try {
      debugPrint('🔐 Sending password reset for: ${user.email}');
      
      final response = await _apiClient.post(
        ApiEndpoints.sendResetLinkEmail,
        data: user.toMap(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Password reset link sent successfully');
        return true;
      }

      throw ApiException('Unexpected response status: ${response.statusCode}', response.statusCode ?? 0);
    } on DioException catch (e) {
      debugPrint('❌ Password reset failed: ${e.message}');
      if (e.response?.data != null) {
        final errorMessage = _extractErrorMessage(e.response!.data);
        throw ApiException(errorMessage, e.response!.statusCode ?? 0);
      }
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected password reset error: $e');
      throw ApiException('Password reset failed: $e', 0);
    }
  }

  /// Update current user profile
  Future<UserModel.User> updateProfile(UserModel.User user) async {
    try {
      if (currentUser.value.id == null) {
        throw ApiException('User not authenticated', 401);
      }

      debugPrint('👤 Updating user profile: ${user.email}');
      
      final response = await _apiClient.put(
        '/users/${currentUser.value.id}',
        data: user.toMap(),
      );

      if (response.data == null) {
        throw ApiException('Empty response from server', response.statusCode ?? 0);
      }

      // Save updated user data
      await _saveUserData(response.data);
      
      final userData = response.data['data'] ?? response.data;
      currentUser.value = UserModel.User.fromJSON(userData);

      debugPrint('✅ User profile updated successfully');
      return currentUser.value;
    } on DioException catch (e) {
      debugPrint('❌ Profile update failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected profile update error: $e');
      throw ApiException('Profile update failed: $e', 0);
    }
  }

  /// Update driver location
  Future<void> updateDriverLocation(double lat, double lng) async {
    try {
      if (currentUser.value.id == null) {
        debugPrint('❌ User not authenticated');
        throw ApiException('User not authenticated', 401);
      }

      debugPrint('📍 Updating driver location: lat=$lat, lng=$lng');

      final response = await _apiClient.post(
        '/api/driver/orders/update-driver-location',
        data: {
          'driver_id': currentUser.value.id,
          'latitude': lat,
          'longitude': lng,
        },
      );

      debugPrint('✅ Driver location updated successfully');
    } on DioException catch (e) {
      debugPrint('❌ Failed to update driver location: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error updating driver location: $e');
      throw ApiException('Failed to update driver location: $e', 0);
    }
  }

  /// Update driver availability status
  Future<void> updateDriverAvailability(bool isAvailable) async {
    try {
      if (currentUser.value.id == null) {
        debugPrint('❌ User not authenticated');
        throw ApiException('User not authenticated', 401);
      }

      debugPrint('🔄 Updating driver availability: $isAvailable');

      final response = await _apiClient.put(
        '/${currentUser.value.id}/update_availability',
        data: {'available': isAvailable},
      );

      debugPrint('✅ Driver availability updated successfully');
    } on DioException catch (e) {
      debugPrint('❌ Failed to update driver availability: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error updating driver availability: $e');
      throw ApiException('Failed to update driver availability: $e', 0);
    }
  }

  /// Upload a document file
  Future<Response> upload(Document document) async {
    try {
      if (document.file == null || !await document.file!.exists()) {
        throw ApiException('File does not exist: ${document.file?.path}', 400);
      }

      if (document.uuid == null || document.uuid!.isEmpty) {
        throw ApiException('Document UUID is required', 400);
      }

      if (document.field == null || document.field!.isEmpty) {
        throw ApiException('Field name is required', 400);
      }

      debugPrint('📤 Uploading file: ${document.file!.path}');
      debugPrint('📝 Document UUID: ${document.uuid}, Field: ${document.field}');

      final response = await _apiClient.uploadFile(
        '/api/uploads',
        fields: {
          'uuid': document.uuid!,
          'field': document.field!,
        },
        files: {
          'file': document.file!,
        },
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = (sent / total * 100).toStringAsFixed(1);
            debugPrint('📤 Upload progress: $progress% ($sent/$total bytes)');
          }
        },
      );

      debugPrint('✅ File uploaded successfully');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ File upload failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected file upload error: $e');
      throw ApiException('File upload failed: $e', 0);
    }
  }

  /// Get current user from storage or memory
  Future<UserModel.User> getCurrentUser() async {
    try {
      if (currentUser.value.auth == null) {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('current_user')) {
          final userJson = prefs.getString('current_user')!;
          currentUser.value = UserModel.User.fromJSON(json.decode(userJson));
          currentUser.value.auth = true;
        } else {
          currentUser.value.auth = false;
        }
      }
      return currentUser.value;
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      currentUser.value.auth = false;
      return currentUser.value;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      debugPrint('🚪 Logging out user');

      // Try to logout on server
      try {
        await _apiClient.post('/auth/logout');
        debugPrint('✅ Server logout successful');
      } catch (e) {
        debugPrint('⚠️ Server logout failed: $e');
      }

      // Clear local data
      await _clearUserData();
      await _apiClient.clearAuthToken();
      
      // Reset current user
      currentUser.value = UserModel.User();
      
      debugPrint('👋 User logged out successfully');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      // Still clear local data even if server logout fails
      await _clearUserData();
      currentUser.value = UserModel.User();
      rethrow;
    }
  }

  /// Get a stream of user's delivery addresses
  /// Returns a stream that emits addresses as they are received
  Future<Stream<Address>> getAddresses() async {
    if (currentUser.value.id == null) {
      throw ApiException('User not authenticated', 401);
    }

    try {
      final response = await _apiClient.get(
        '/delivery_addresses',
        queryParameters: {
          'search': 'user_id:${currentUser.value.id}',
          'searchFields': 'user_id:=',
          'orderBy': 'is_default',
          'sortedBy': 'desc',
        },
        options: Options(
          responseType: ResponseType.stream,
          receiveDataWhenStatusError: true,
        ),
      );

      // Handle the response as a stream
      if (response.data is Stream) {
        return (response.data as Stream).transform(utf8.decoder)
          .transform(json.decoder)
          .map((data) => data is Map ? data : json.decode(data as String))
          .map((data) => data['data'] ?? data)
          .expand((data) => data is List ? data : [])
          .map((data) => Address.fromJSON(data));
      } else {
        // Fallback to single response handling
        final data = response.data['data'] ?? response.data;
        final addresses = data is List ? data : [];
        return Stream.fromIterable(
          addresses.map((json) => Address.fromJSON(json)),
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Failed to get addresses: ${e.message}');
      return Stream.error(e);
    } catch (e) {
      debugPrint('❌ Unexpected error getting addresses: $e');
      return Stream.value(Address.fromJSON({}));
    }
  }

  Future<Address> addAddress(Address address) async {
    try {
      if (currentUser.value.id == null) {
        throw ApiException('User not authenticated', 401);
      }

      address.userId = currentUser.value.id;
      
      final response = await _apiClient.post(
        '/delivery_addresses',
        data: address.toMap(),
      );

      final data = response.data['data'] ?? response.data;
      return Address.fromJSON(data);
    } on DioException catch (e) {
      debugPrint('❌ Failed to add address: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error adding address: $e');
      throw ApiException('Failed to add address: $e', 0);
    }
  }

  Future<Address> updateAddress(Address address) async {
    try {
      if (currentUser.value.id == null) {
        throw ApiException('User not authenticated', 401);
      }

      address.userId = currentUser.value.id;
      
      final response = await _apiClient.put(
        '/delivery_addresses/${address.id}',
        data: address.toMap(),
      );

      final data = response.data['data'] ?? response.data;
      return Address.fromJSON(data);
    } on DioException catch (e) {
      debugPrint('❌ Failed to update address: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error updating address: $e');
      throw ApiException('Failed to update address: $e', 0);
    }
  }

  Future<Address> removeAddress(Address address) async {
    try {
      final response = await _apiClient.delete(
        '/delivery_addresses/${address.id}',
      );

      final data = response.data['data'] ?? response.data;
      return Address.fromJSON(data);
    } on DioException catch (e) {
      debugPrint('❌ Failed to remove address: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error removing address: $e');
      throw ApiException('Failed to remove address: $e', 0);
    }
  }

  /// Credit card management
  Future<void> saveCreditCard(CreditCard creditCard) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('credit_card', json.encode(creditCard.toMap()));
      debugPrint('✅ Credit card saved successfully');
    } catch (e) {
      debugPrint('❌ Failed to save credit card: $e');
      throw ApiException('Failed to save credit card: $e', 0);
    }
  }

  Future<CreditCard> getCreditCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('credit_card')) {
        final cardJson = prefs.getString('credit_card')!;
        return CreditCard.fromJSON(json.decode(cardJson));
      }
      return CreditCard();
    } catch (e) {
      debugPrint('❌ Failed to get credit card: $e');
      return CreditCard();
    }
  }

  /// Private helper methods
  Future<void> _saveUserData(Map<String, dynamic> responseData) async {
    try {
      final userData = responseData['data'];
      if (userData != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', json.encode(userData));
        debugPrint('✅ User data saved to storage');
      }
    } catch (e) {
      debugPrint('❌ Failed to save user data: $e');
      throw ApiException('Failed to save user data: $e', 0);
    }
  }

  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      debugPrint('✅ User data cleared from storage');
    } catch (e) {
      debugPrint('❌ Failed to clear user data: $e');
    }
  }

  String _extractErrorMessage(dynamic data) {
    try {
      if (data is Map) {
        return data['message']?.toString() ?? 
               data['error']?.toString() ?? 
               data['detail']?.toString() ??
               'Request failed';
      } else if (data is String) {
        try {
          final jsonData = json.decode(data);
          if (jsonData is Map) {
            return jsonData['message']?.toString() ?? 
                   jsonData['error']?.toString() ?? 
                   jsonData['detail']?.toString() ??
                   'Request failed';
          }
        } catch (_) {
          return data;
        }
      }
      return data.toString();
    } catch (_) {
      return 'Request failed';
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Global instance for easy access
final UserRepository userRepository = UserRepository();