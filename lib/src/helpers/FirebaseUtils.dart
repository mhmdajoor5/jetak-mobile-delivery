import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user.dart' as UserModel;
import '../repository/user_repository.dart' as userRepo;

class FirebaseUtil {
  static final FirebaseUtil _singleton = FirebaseUtil._internal();

  static late FirebaseMessaging _firebaseMessaging;

  factory FirebaseUtil() {
    return _singleton;
  }

  FirebaseUtil._internal();

  static FirebaseUtil getInstance() {
    return _singleton;
  }

  static Future<UserModel.User> getUser() async {
    return await userRepo.userRepository.getCurrentUser();
  }

  /// Get FCM device token
  static Future<String> getDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('🔑 FCM Token: $token');
        return token;
        // You can send this token to your backend or save it
      } else {
        print('❌ Failed to get FCM token');
        return '';
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return '';
    }
  }

  static Future<void> registerFCM() async {
    try {
      String? deviceToken = await getDeviceToken();
      print('Notification: $deviceToken');

      UserModel.User? currentUser = await userRepo.userRepository.getCurrentUser();
      currentUser.deviceToken = deviceToken;
      await userRepo.userRepository.updateProfile(currentUser);
            } catch (e) {
      print('Notification not configured');
      print(e);
    }
  }


// static void registerFCM(User user) {
  //   _firebaseMessaging = FirebaseMessaging.instance;
  //   _firebaseMessaging.getToken().then((String _deviceToken) async  {
  //     print('Notification: $_deviceToken');
  //     user.deviceToken = _deviceToken;
  //     await userRepo.update(user);
  //   } as FutureOr<Null> Function(String? value)).catchError((e) {
  //     print(e);
  //     print('Notification not configured');
  //   });
  // }
}