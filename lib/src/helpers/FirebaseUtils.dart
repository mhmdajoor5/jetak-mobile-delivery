import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../models/user.dart' as UserModel;
import '../repository/user_repository.dart' as userRepo;

class FirebaseUtil {
  static final FirebaseUtil _singleton = FirebaseUtil._internal();

  static late FirebaseMessaging _firebaseMessaging;
  static bool _isTokenRefreshListenerSetup = false;
  static bool? _isSimulator;

  factory FirebaseUtil() {
    return _singleton;
  }

  FirebaseUtil._internal();

  static FirebaseUtil getInstance() {
    return _singleton;
  }

  static Future<UserModel.User> getUser() async {
    return await userRepo.getCurrentUser();
  }

  /// Check if running on iOS Simulator
  /// iOS Simulator cannot receive push notifications and won't have APNS token
  static Future<bool> isIOSSimulator() async {
    if (_isSimulator != null) {
      return _isSimulator!;
    }

    if (!Platform.isIOS) {
      _isSimulator = false;
      return false;
    }

    try {
      // On iOS Simulator, APNS token will be null even after waiting
      // On real device, APNS token should be available
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();

      if (apnsToken == null) {
        // Wait a bit and try again to be sure
        await Future.delayed(Duration(seconds: 3));
        final retryToken = await FirebaseMessaging.instance.getAPNSToken();

        if (retryToken == null) {
          // Still null = likely simulator
          _isSimulator = true;
          print('📱 Detected iOS Simulator (no APNS token available)');
          return true;
        }
      }

      _isSimulator = false;
      print('📱 Detected real iOS device (APNS token available)');
      return false;
    } catch (e) {
      print('⚠️ Error checking iOS simulator status: $e');
      // Assume not simulator to be safe
      _isSimulator = false;
      return false;
    }
  }

  /// Request notification permissions (especially important for iOS)
  static Future<bool> requestNotificationPermission() async {
    try {
      print('🔔 Requesting notification permissions...');

      final messaging = FirebaseMessaging.instance;

      // Request permission (important for iOS)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('Notif permission: ${settings.authorizationStatus}');
      final fcm = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM TOKEN: $fcm');

      final apns = await FirebaseMessaging.instance.getAPNSToken();
      debugPrint('APNS TOKEN: $apns');

      print('📱 Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');
        return true;
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('✅ User granted provisional notification permission');
        return true;
      } else {
        print('⚠️ User declined notification permission');
        return false;
      }
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Get FCM device token (after requesting permission)
  static Future<String> getDeviceToken() async {
    try {
      print('🔑 Getting FCM device token...');

      // Force refresh token to solve 404/invalid token issues
      try {
        print('🗑️ Deleting current token to force a fresh one...');
        await FirebaseMessaging.instance.deleteToken();
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        print('ℹ️ No existing token to delete or delete failed');
      }

      // Check if running on iOS Simulator
      if (Platform.isIOS) {
        bool isSimulator = await isIOSSimulator();
        if (isSimulator) {
          print('⚠️ Running on iOS Simulator - FCM tokens are not available');
          print('⚠️ Push notifications only work on real iOS devices');
          print('⚠️ Skipping FCM token retrieval');
          return '';
        }

        // Real iOS device - get APNS token first
        String? apnsToken;
        int retries = 0;
        while (apnsToken == null && retries < 10) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            print('⏳ Waiting for APNS token (attempt ${retries + 1}/10)...');
            await Future.delayed(Duration(seconds: 2));
            retries++;
          }
        }
        
        print('📱 iOS APNS Token: ${apnsToken ?? "Still not available"}');

        if (apnsToken == null) {
          print('❌ APNS token still not available after $retries retries');
          print('⚠️ This may affect push notification delivery');
        }
      }

      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        print('✅ FCM Token retrieved successfully');
        print('🔑 Token (first 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
        print('🔑 Token length: ${token.length} characters');
        print('🔔 FCM Token obtained: $token');
        return token;
      } else {
        print('❌ Failed to get FCM token - token is null or empty');
        return '';
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return '';
    }
  }

  /// Setup token refresh listener
  static void setupTokenRefreshListener() {
    if (_isTokenRefreshListenerSetup) {
      print('⚠️ Token refresh listener already setup, skipping...');
      return;
    }

    try {
      print('🔄 Setting up FCM token refresh listener...');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print('🔄 FCM Token refreshed!');
        print('🔑 New token (first 20 chars): ${newToken.substring(0, newToken.length > 20 ? 20 : newToken.length)}...');

        try {
          // Save the new token to backend
          UserModel.User currentUser = await userRepo.getCurrentUser();

          if (currentUser.auth == true && currentUser.id != null) {
            print('💾 Saving refreshed token to backend for user ID: ${currentUser.id}');
            currentUser.deviceToken = newToken;
            await userRepo.update(currentUser);
            print('✅ Refreshed token saved successfully');
          } else {
            print('⚠️ User not authenticated, cannot save refreshed token');
          }
        } catch (e) {
          print('❌ Error saving refreshed token: $e');
        }
      }, onError: (error) {
        print('❌ Error in token refresh listener: $error');
      });

      _isTokenRefreshListenerSetup = true;
      print('✅ Token refresh listener setup complete');
    } catch (e) {
      print('❌ Error setting up token refresh listener: $e');
    }
  }

  /// Register FCM with complete flow
  static Future<void> registerFCM() async {
    try {
      print('');
      print('═══════════════════════════════════════');
      print('🚀 Starting FCM Registration Process');
      print('═══════════════════════════════════════');
      print('📱 Platform: ${Platform.operatingSystem}');

      // Log Firebase configuration details
      try {
        final options = Firebase.app().options;
        print('🔥 Firebase Project ID: ${options.projectId}');
        print('🔥 Firebase App ID: ${options.appId}');
        print('🔥 Firebase Sender ID: ${options.messagingSenderId}');
      } catch (e) {
        print('⚠️ Could not log Firebase options: $e');
      }

      // Check for iOS Simulator early
      if (Platform.isIOS) {
        bool isSimulator = await isIOSSimulator();
        if (isSimulator) {
          print('');
          print('⚠️ ════════════════ SIMULATOR DETECTED ════════════════');
          print('⚠️ Running on iOS Simulator');
          print('⚠️ FCM Push Notifications are NOT supported on iOS Simulator');
          print('⚠️ To test push notifications, use a real iOS device');
          print('⚠️ Skipping FCM registration...');
          print('⚠️ ═══════════════════════════════════════════════════');
          print('═══════════════════════════════════════');
          print('');
          return;
        } else {
          print('✅ Running on real iOS device - FCM will work properly');
        }
      }

      // Step 1: Setup token refresh listener (do this first, only once)
      setupTokenRefreshListener();

      // Step 2: Request notification permission
      print('');
      print('📋 Step 1/3: Requesting notification permission...');
      bool hasPermission = await requestNotificationPermission();

      if (!hasPermission) {
        print('⚠️ Warning: Notification permission not granted');
        print('⚠️ FCM token may not work properly without permission');
        // Continue anyway as some Android versions don't require explicit permission
      }

      // Step 3: Get device token
      print('');
      print('📋 Step 2/3: Getting FCM device token...');
      String? deviceToken = await getDeviceToken();

      if (deviceToken.isEmpty) {
        print('❌ Failed to get device token, aborting registration');
        print('═══════════════════════════════════════');
        return;
      }

      print('✅ Device token obtained: ${deviceToken.substring(0, 20)}...');

      // Step 4: Save to backend
      print('');
      print('📋 Step 3/3: Saving token to backend...');
      UserModel.User currentUser = await userRepo.getCurrentUser();

      if (currentUser.auth != true || currentUser.id == null) {
        print('⚠️ User not authenticated yet');
        print('⚠️ Token: $deviceToken');
        print('⚠️ Token will be saved after login');
        print('═══════════════════════════════════════');
        return;
      }

      print('💾 Saving token for user ID: ${currentUser.id}');
      print('📧 User email: ${currentUser.email}');

      currentUser.deviceToken = deviceToken;
      await userRepo.update(currentUser);

      print('✅ FCM token saved to backend successfully!');
      print('═══════════════════════════════════════');
      print('');
    } catch (e) {
      print('');
      print('❌ FCM Registration Error: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      print('═══════════════════════════════════════');
      print('');
    }
  }

  /// Save FCM token for a specific user (called after login/registration)
  static Future<void> saveFCMTokenForUser(UserModel.User user) async {
    try {
      print('');
      print('═══════════════════════════════════════');
      print('💾 Saving FCM token for logged in user');
      print('═══════════════════════════════════════');
      print('👤 User ID: ${user.id}');
      print('📧 Email: ${user.email}');
      print('📱 Platform: ${Platform.operatingSystem}');

      // Check for iOS Simulator
      if (Platform.isIOS) {
        bool isSimulator = await isIOSSimulator();
        if (isSimulator) {
          print('');
          print('⚠️ ════════════════ SIMULATOR DETECTED ════════════════');
          print('⚠️ Running on iOS Simulator');
          print('⚠️ FCM tokens are not available on iOS Simulator');
          print('⚠️ Skipping FCM token save for this user');
          print('⚠️ User can still login, but won\'t receive push notifications');
          print('⚠️ Use a real iOS device to test push notifications');
          print('⚠️ ═══════════════════════════════════════════════════');
          print('═══════════════════════════════════════');
          print('');
          return;
        } else {
          print('✅ Running on real iOS device');
        }
      }

      // Request permission first
      await requestNotificationPermission();

      // Get token
      String? deviceToken = await getDeviceToken();

      if (deviceToken.isEmpty) {
        print('❌ Failed to get device token');
        print('═══════════════════════════════════════');
        return;
      }

      print('🔑 Token obtained: ${deviceToken.substring(0, 20)}...');

      // Update user object
      user.deviceToken = deviceToken;

      // Save to backend
      print('💾 Updating user with FCM token...');
      await userRepo.update(user);

      print('✅ FCM token saved successfully for user after login!');
      print('═══════════════════════════════════════');
      print('');
    } catch (e) {
      print('❌ Error saving FCM token for user: $e');
      print('═══════════════════════════════════════');
    }
  }
}
