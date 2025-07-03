import 'package:deliveryboy/src/models/user.dart';
import 'package:deliveryboy/src/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/driver_status_helper.dart';
import '../models/order.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/user_repository.dart' as userRepo;

class OrderController extends ControllerMVC {
  List<Order> orders = <Order>[];
  bool driverAvailability = false;
  late GlobalKey<ScaffoldState> scaffoldKey;

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void getCurrentUserStatus() {
    userRepo.getCurrentUserAsync().asStream().listen((event) async {
      driverAvailability =
          (await userRepo.getCurrentUserAsync()).available == true;
      setState(() {});
    });
  }

  Future<void> updateCurrentUserStatus(bool value) async {
    setState(() {
      driverAvailability = value;
    });
    await DriverStatusUtil.updateDriverStatus(value);
  }

  void listenForOrders({String? message}) async {
    // **DEBUG: فحص حالة المستخدم والتوكن**
    print('🔍 Checking user authentication status...');
    User currentUser = userRepo.currentUser.value;

    print('🔍 User Authentication Check:');
    print('   - User ID: ${currentUser.id}');
    print('   - User Email: ${currentUser.email}');
    print('   - Has API Token: ${currentUser.apiToken != null}');
    print('   - Token Length: ${currentUser.apiToken?.length ?? 0}');
    print(
      '   - Is User Logged In: ${currentUser.id != null && currentUser.apiToken != null}',
    );

    if (currentUser.apiToken == null || currentUser.apiToken!.isEmpty) {
      print('❌ CRITICAL: User has no API token!');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('⚠️ Authentication Error: Please login again'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // **DEBUG: اختبار الاتصال أولاً**
    print('🔍 Running API connection test...');
    try {
      final testResult = await orderRepo.testConnection();
      print('🔍 Test Result Summary:');
      print('   - Success: ${testResult['success']}');
      print('   - Issue Type: ${testResult['issue'] ?? 'unknown'}');
      print('   - Message: ${testResult['message']}');
      print('   - Status Code: ${testResult['status_code']}');

      if (!testResult['success']) {
        print('❌ API Connection Test Failed:');
        print('   Issue: ${testResult['issue']}');

        // عرض رسالة مناسبة للمستخدم حسب نوع المشكلة
        String userMessage = '';
        Color messageColor = Colors.red;

        switch (testResult['issue']) {
          case 'mobile_app':
            userMessage = '🔑 Please login again - Authentication expired';
            break;
          case 'authentication':
            userMessage = '🚫 Authentication failed - Please login again';
            break;
          case 'endpoint':
            userMessage = '🔗 Server connection issue - Contact support';
            break;
          case 'backend_config':
            userMessage = '⚙️ Server configuration issue - Contact support';
            break;
          case 'backend_error':
            userMessage = '💥 Server error - Please try again later';
            break;
          case 'network':
            userMessage = '📶 Network connection issue - Check internet';
            break;
          default:
            userMessage = '❌ Connection failed - Please try again';
        }

        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: messageColor,
            duration: Duration(seconds: 5),
          ),
        );

        // إذا كانت مشكلة authentication، ما نكمل
        if (testResult['issue'] == 'authentication' ||
            testResult['issue'] == 'mobile_app') {
          return;
        }
      }
    } catch (testError) {
      print('❌ Test Connection Error: $testError');
    }

    final Stream<Order> stream = await orderRepo.getNewPendingOrders();
    stream.listen(
      (Order _order) {
        setState(() {
          orders.add(_order);
        });
      },
      onError: (a) {
        print('❌ Stream Error: $a');
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('Connection Error: ${a.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onDone: () {
        if (message != null) {
          ScaffoldMessenger.of(
            scaffoldKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
  }

  void acceptOrder(int orderID) async {
    try {
      print('🔄 Accepting order: $orderID');
      final result = await orderRepo.acceptOrderWithId(orderID.toString());

      if (result['success'] == true) {
        print('✅ Order $orderID accepted successfully');
        // إعادة تحميل الطلبات بعد القبول
        refreshOrders();

        // إظهار رسالة نجاح
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('✅ Order accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('❌ Failed to accept order $orderID: ${result['message']}');
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to accept order: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error accepting order $orderID: $e');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('❌ Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void rejectOrder(int orderID) async {
    try {
      print('🔄 Rejecting order: $orderID');
      final result = await orderRepo.rejectOrderWithId(orderID.toString());

      if (result['success'] == true) {
        print('❌ Order $orderID rejected successfully');
        // إزالة الطلب من القائمة بعد الرفض
        setState(() {
          orders.removeWhere((order) => order.id == orderID.toString());
        });

        // إظهار رسالة نجاح
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('❌ Order rejected successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        print('❌ Failed to reject order $orderID: ${result['message']}');
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to reject order: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error rejecting order $orderID: $e');
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('❌ Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void listenForOrdersHistory({String? message}) async {
    final Stream<Order> stream = await orderRepo.getOrdersHistory();
    stream.listen(
      (Order _order) {
        setState(() {
          orders.add(_order);
        });
      },
      onError: (a) {
        print(a);
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(S.of(state!.context).verify_your_internet_connection),
          ),
        );
      },
      onDone: () {
        if (message != null) {
          ScaffoldMessenger.of(
            scaffoldKey.currentContext!,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
  }

  Future<void> refreshOrdersHistory() async {
    orders.clear();
    listenForOrdersHistory(
      message: S.of(state!.context).order_refreshed_successfuly,
    );
  }

  Future<void> refreshOrders() async {
    try {
      print('🔄 Refreshing orders...');
      orders.clear();
      setState(() {}); // Update UI immediately after clearing
      listenForOrders(
        message: S.of(state!.context).order_refreshed_successfuly,
      );
      print('✅ Orders refresh initiated');
    } catch (e) {
      print('❌ Error refreshing orders: $e');
    }
  }
}
