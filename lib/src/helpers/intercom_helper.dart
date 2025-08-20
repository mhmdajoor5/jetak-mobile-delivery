import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class IntercomHelper {
  static const String _appId = 'j3he2pue';
  static const String _iosApiKey = 'ios_sdk-9dd934131d451492917c16a61a9ec34824400eee';
  static const String _androidApiKey = 'android_sdk-d8df6307ae07677807b288a2d5138821b8bfe4f9';

  static final Intercom _intercom = Intercom.instance;

  /// تهيئة Intercom
  static Future<void> initialize() async {
    try {
      await _intercom.initialize(
        _appId,
        iosApiKey: _iosApiKey,
        androidApiKey: _androidApiKey,
      );
      debugPrint('✅ Intercom initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Intercom: $e');
    }
  }

  /// تسجيل المستخدم في Intercom
  static Future<void> loginUser({
    required String userId,
    required String email,
    String? name,
    Map<String, dynamic>? attributes,
  }) async {
    try {
      await _intercom.loginIdentifiedUser(
        userId: userId,
        email: email,
      );
      
      if (name != null) {
        await _intercom.updateUser(
          name: name,
          customAttributes: attributes ?? {},
        );
      }
      
      debugPrint('✅ User logged in to Intercom: $email');
    } catch (e) {
      debugPrint('❌ Error logging user to Intercom: $e');
    }
  }

  /// تسجيل الخروج من Intercom
  static Future<void> logout() async {
    try {
      await _intercom.logout();
      debugPrint('✅ User logged out from Intercom');
    } catch (e) {
      debugPrint('❌ Error logging out from Intercom: $e');
    }
  }

  /// تسجيل مستخدم غير محدد (للزوار)
  static Future<void> loginUnidentifiedUser() async {
    try {
      await _intercom.loginUnidentifiedUser();
      debugPrint('✅ Unidentified user logged in to Intercom');
    } catch (e) {
      debugPrint('❌ Error logging unidentified user to Intercom: $e');
    }
  }

  /// التحقق من الاتصال بالإنترنت
  static Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// عرض مساعد Intercom
  static Future<void> displayMessenger() async {
    try {
      // التحقق من الاتصال أولاً
      debugPrint('🔄 Checking internet connection...');
      final hasInternet = await _checkInternetConnection();
      
      if (!hasInternet) {
        throw Exception('No internet connection available');
      }
      
      debugPrint('🔄 Attempting to display Intercom messenger...');
      
      await _intercom.displayMessenger();
      debugPrint('✅ Intercom messenger displayed successfully');
    } catch (e) {
      debugPrint('❌ Error displaying Intercom messenger: $e');
      debugPrint('🔍 Error details: ${e.toString()}');
      
      // محاولة إعادة التهيئة إذا فشل
      try {
        debugPrint('🔄 Attempting to reinitialize Intercom...');
        await initialize();
        await Future.delayed(Duration(seconds: 2));
        await _intercom.displayMessenger();
        debugPrint('✅ Intercom messenger displayed after reinitialization');
      } catch (reinitError) {
        debugPrint('❌ Failed to reinitialize Intercom: $reinitError');
        throw Exception('Failed to load Intercom messenger. Please check your internet connection and try again.');
      }
    }
  }

  /// عرض مساعد Intercom مع رسالة مخصصة
  static Future<void> displayMessageComposer({
    String? message,
  }) async {
    try {
      await _intercom.displayMessageComposer(message ?? '');
      debugPrint('✅ Intercom message composer displayed');
    } catch (e) {
      debugPrint('❌ Error displaying Intercom message composer: $e');
    }
  }

  /// عرض مساعد Intercom مع مسار مخصص
  static Future<void> displayHelpCenter() async {
    try {
      await _intercom.displayHelpCenter();
      debugPrint('✅ Intercom help center displayed');
    } catch (e) {
      debugPrint('❌ Error displaying Intercom help center: $e');
    }
  }

  /// تحديث بيانات المستخدم
  static Future<void> updateUser({
    String? name,
    String? email,
    String? phone,
    Map<String, dynamic>? customAttributes,
  }) async {
    try {
      await _intercom.updateUser(
        name: name,
        email: email,
        phone: phone,
        customAttributes: customAttributes ?? {},
      );
      debugPrint('✅ User updated in Intercom');
    } catch (e) {
      debugPrint('❌ Error updating user in Intercom: $e');
    }
  }

  /// إضافة حدث مخصص
  static Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _intercom.logEvent(eventName, metadata);
      debugPrint('✅ Event logged to Intercom: $eventName');
    } catch (e) {
      debugPrint('❌ Error logging event to Intercom: $e');
    }
  }

  /// التحقق من وجود رسائل غير مقروءة
  static Future<bool> hasUnreadConversations() async {
    try {
      // Note: hasUnreadConversations might not be available in all versions
      // For now, we'll return false as a fallback
      debugPrint('📬 Checking unread conversations (not implemented)');
      return false;
    } catch (e) {
      debugPrint('❌ Error checking unread conversations: $e');
      return false;
    }
  }

  /// إخفاء مساعد Intercom
  static Future<void> hideMessenger() async {
    try {
      await _intercom.hideMessenger();
      debugPrint('✅ Intercom messenger hidden');
    } catch (e) {
      debugPrint('❌ Error hiding Intercom messenger: $e');
    }
  }

}
