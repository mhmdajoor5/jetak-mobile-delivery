import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

class FirebaseUtil {
  static final FirebaseUtil _singleton = FirebaseUtil._internal();

  static late FirebaseMessaging _firebaseMessaging;

  factory FirebaseUtil() {
    return _singleton;
  }

  FirebaseUtil._internal();

  static getInstance() {
    return _singleton;
  }

  static Future<User> getUser() async {
    return await userRepo.getCurrentUser();
  }

  static Future<void> registerFCM(User user) async {
    try {
      String? deviceToken = await _firebaseMessaging.getToken();
      print('Notification: $deviceToken');

      if (deviceToken != null) {
        user.deviceToken = deviceToken;
        await userRepo.update(user);
      } else {
        print('Failed to get FCM token');
      }
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