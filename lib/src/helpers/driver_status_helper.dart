
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

class DriverStatusUtil {
  static final DriverStatusUtil _singleton = DriverStatusUtil._internal();

  static bool driverStatus = true;

  factory DriverStatusUtil() {
    return _singleton;
  }

  DriverStatusUtil._internal();

  static DriverStatusUtil getInstance() {
    return _singleton;
  }

  static Future<User> getUser() async {
    return await userRepo.userRepository.getCurrentUser();
  }

  static Future<void> updateDriverStatus(bool value)  async {
    driverStatus = value;
    await userRepo.userRepository.updateDriverAvailability(value);
  }
}