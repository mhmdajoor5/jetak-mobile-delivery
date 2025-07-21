class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://carrytechnologies.co/api';
  static const String baseUrlAlt = 'http://ec2-51-17-253-70.il-central-1.compute.amazonaws.com/api';

  // Auth endpoints
  static const String login = '/login';
  static const String socialLogin = '/login/social/google';
  static const String verifyPhone = '/verifyPhone';
  static const String sendSms = '/send-sms';
  static const String submitOtp = '/submit-otp';
  static const String user = '/user';
  static const String register = '/register';
  static const String forgetPassword = '/forget-password';
  static const String sendResetLinkEmail = '/send-reset-link-email';

  // Address endpoints
  static const String deliveryAddresses = '/delivery_addresses';
  static String getAddress(String id) => '$deliveryAddresses/$id';
  static String updateAddress(String id) => '$deliveryAddresses/$id';
  static String deleteAddress(String id) => '$deliveryAddresses/$id';

  // Order endpoints
  static const String orders = '/orders';
  static String order(String id) => '$orders/$id';
  static String orderStatusHistory(String orderId) => '$orders/$orderId/status-history';
  static const String checkDelivery = '/check-delivery';

  // Driver endpoints
  static const String driver = '/driver';
  static const String acceptOrder = '$driver/accept-order-by-driver';
  static const String rejectOrder = '$driver/reject-order-by-driver';
  static String driverCandidateOrders(String driverId) => '$driver/driver-candidate-orders/$driverId';
  static const String updateDriverLocation = '$driver/orders/update-driver-location';

  // Restaurant endpoints
  static const String restaurants = '/restaurants';

  // Cart endpoints
  static const String carts = '/carts';
  static String cart(String id) => '$carts/$id';

  // Notification endpoints
  static const String notifications = '/notifications';

  // Helper methods
  static String withToken(String endpoint, {required String token}) {
    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint${separator}api_token=$token';
  }

  // Full URL getters
  static String getLoginUrl() => '$baseUrl$login';
  static String getSocialLoginUrl() => '$baseUrl$socialLogin';
  static String getVerifyPhoneUrl() => '$baseUrl$verifyPhone';
  static String getSendSmsUrl() => '$baseUrl$sendSms';
  static String getSubmitOtpUrl() => '$baseUrl$submitOtp';
  static String getUserUrl() => '$baseUrl$user';
  static String getDeliveryAddressesUrl() => '$baseUrl$deliveryAddresses';
  static String getAddressUrl(String id) => '$baseUrl${getAddress(id)}';
  static String getUpdateAddressUrl(String id) => '$baseUrl${updateAddress(id)}';
  static String getDeleteAddressUrl(String id) => '$baseUrl${deleteAddress(id)}';
  static String getOrdersUrl() => '$baseUrl$orders';
  static String getOrderUrl(String id) => '$baseUrl${order(id)}';
  static String getOrderStatusHistoryUrl(String orderId) => '$baseUrl${orderStatusHistory(orderId)}';
  static String getCheckDeliveryUrl() => '$baseUrl$checkDelivery';
  static String getAcceptOrderUrl() => '$baseUrl$acceptOrder';
  static String getRejectOrderUrl() => '$baseUrl$rejectOrder';
  static String getDriverCandidateOrdersUrl(String driverId) => '$baseUrl${driverCandidateOrders(driverId)}';
  static String getUpdateDriverLocationUrl() => '$baseUrl$updateDriverLocation';
  static String getRestaurantsUrl() => '$baseUrl$restaurants';
  static String getCartsUrl() => '$baseUrl$carts';
  static String getCartUrl(String id) => '$baseUrl${cart(id)}';
  static String getNotificationsUrl() => '$baseUrl$notifications';
}
