import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

class DriverStatusUtil {
  static final DriverStatusUtil _singleton = DriverStatusUtil._internal();

  static bool driverStatus = true;

  factory DriverStatusUtil() {
    return _singleton;
  }

  DriverStatusUtil._internal();

  static getInstance() {
    return _singleton;
  }

  static Future<User> getUser() async {
    return await userRepo.getCurrentUser();
  }

  static Future<void> updateDriverStatus(bool value)  async {
    driverStatus = value;
    await userRepo.updateDriverAvailability(value);
  }
}