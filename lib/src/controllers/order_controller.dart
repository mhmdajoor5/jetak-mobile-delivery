import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/driver_status_helper.dart';
import '../helpers/PusherHelper.dart';
import '../models/order.dart';
import '../models/pending_order_model.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/orders/pending_order_repo.dart' as pendingRepo;
import '../repository/user_repository.dart' as userRepo;

class OrderController extends ControllerMVC {
  List<Order> orders = <Order>[];
  List<PendingOrderModel> pendingOrdersModel = <PendingOrderModel>[];
  bool driverAvailability = false;
  bool isLoadingOrders = false;
  bool isAcceptingOrder = false;
  bool isRejectingOrder = false;
  late GlobalKey<ScaffoldState> scaffoldKey;

  OrderController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void getCurrentUserStatus() {
    userRepo.getCurrentUser().asStream().listen((event) async {
      driverAvailability =
          (await userRepo.getCurrentUser()).available == true;
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
    final currentUser = userRepo.currentUser.value;

    if (currentUser.apiToken == null || currentUser.apiToken!.isEmpty) {
      final context = scaffoldKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Authentication Error: Please login again'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    try {
      final testResult = await orderRepo.testConnection();
    
      if (!testResult['success']) {
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

        final context = scaffoldKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userMessage),
              backgroundColor: messageColor,
              duration: Duration(seconds: 5),
            ),
          );
        }

        if (testResult['issue'] == 'authentication' || testResult['issue'] == 'mobile_app') {
          return;
        }
      }
    } catch (testError) {
    }


    // Fetch pending orders using new repo
    try {
      final response = await pendingRepo.getPendingOrders(driverId: currentUser.id.toString());

      // Parse response into PendingOrdersModel
      final parsedOrders = PendingOrdersModel.fromJson(response);
      
      

      // Update your list
      setState(() {
        pendingOrdersModel = parsedOrders.orders;
      });


      if (message != null) {
        final context = scaffoldKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }

    } catch (err) {
      final context = scaffoldKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to fetch pending orders: ${err.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> acceptOrder(String orderID) async {
    if (isAcceptingOrder) {
      return {
        'success': false,
        'message': 'Request already in progress',
      };
    }

    setState(() {
      isAcceptingOrder = true;
    });

    try {
      print('📤 Accepting order $orderID...');

      final result = await orderRepo.acceptOrderWithId(orderID);

      if (result['success']) {
        print('✅ Order $orderID accepted successfully');

        // Mark order as processed in Pusher to prevent duplicate notifications
        PusherHelper.markOrderAsProcessed(orderID);

        // Remove the order from pending list
        setState(() {
          pendingOrdersModel.removeWhere((order) => order.orderId.toString() == orderID);
        });

        // Refresh orders list
        await refreshOrders();

        return {
          'success': true,
          'message': 'Order accepted successfully',
          'data': result['data'],
        };
      } else {
        print('❌ Failed to accept order $orderID: ${result['message']}');

        return {
          'success': false,
          'message': result['message'] ?? 'Failed to accept order',
        };
      }
    } catch (e) {
      print('❌ Error accepting order $orderID: $e');

      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.',
        'error': e.toString(),
      };
    } finally {
      setState(() {
        isAcceptingOrder = false;
      });
    }
  }

  Future<Map<String, dynamic>> rejectOrder(String orderID) async {
    if (isRejectingOrder) {
      return {
        'success': false,
        'message': 'Request already in progress',
      };
    }

    setState(() {
      isRejectingOrder = true;
    });

    try {
      print('🚫 Rejecting order $orderID...');

      final result = await orderRepo.rejectOrderWithId(orderID);

      if (result['success']) {
        print('✅ Order $orderID rejected successfully');

        // Mark order as processed in Pusher to prevent duplicate notifications
        PusherHelper.markOrderAsProcessed(orderID);

        // Remove the order from pending list
        setState(() {
          pendingOrdersModel.removeWhere((order) => order.orderId.toString() == orderID);
        });

        // Refresh orders list
        await refreshOrders();

        return {
          'success': true,
          'message': 'Order rejected successfully',
        };
      } else {
        print('❌ Failed to reject order $orderID: ${result['message']}');

        return {
          'success': false,
          'message': result['message'] ?? 'Failed to reject order',
        };
      }
    } catch (e) {
      print('❌ Error rejecting order $orderID: $e');

      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.',
        'error': e.toString(),
      };
    } finally {
      setState(() {
        isRejectingOrder = false;
      });
    }
  }

  void listenForOrdersHistory({String? message}) async {
    final Stream<Order> stream = await orderRepo.getOrdersHistory();
    stream.listen(
      (Order order) {
        setState(() {
          orders.add(order);
        });
      },
      onError: (a) {
        print(a);
        final context = scaffoldKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(state!.context).verify_your_internet_connection),
            ),
          );
        }
      },
      onDone: () {
        if (message != null) {
          final context = scaffoldKey.currentContext;
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          }
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

  // إضافة دالة تحديث الطلبات
  Future<void> refreshOrders() async {
    print('🔄 Controller - Refreshing orders list');
    listenForOrders();
  }
}
