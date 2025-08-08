import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/driver_status_helper.dart';
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
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('⚠️ Authentication Error: Please login again'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
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

        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: messageColor,
            duration: Duration(seconds: 5),
          ),
        );

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
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

    } catch (err) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to fetch pending orders: ${err.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }

  Future<void> acceptOrder(String orderID) async {
    if (isAcceptingOrder) return; // Prevent multiple simultaneous accepts
    
    setState(() {
      isAcceptingOrder = true;
    });

    try {
      
      final result = await orderRepo.acceptOrderWithId(orderID);

      if (result['success']) {
        
        // Remove the order from pending list
        setState(() {
          pendingOrdersModel.removeWhere((order) => order.orderId.toString() == orderID);
          isAcceptingOrder = false;
        });
        
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.green, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🎉 تم قبول الطلب بنجاح!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'طلب #$orderID - يمكنك الآن البدء في التوصيل',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        // Refresh orders list
        await refreshOrders();
      } else {
        print('❌ Failed to accept order $orderID: ${result['message']}');
        setState(() {
          isAcceptingOrder = false;
        });
        
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '❌ فشل في قبول الطلب',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        result['message'] ?? 'خطأ غير معروف',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error accepting order $orderID: $e');
      setState(() {
        isAcceptingOrder = false;
      });
      
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🌐 خطأ في الاتصال',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'تحقق من اتصال الإنترنت وحاول مرة أخرى',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[600],
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> rejectOrder(String orderID) async {
    if (isRejectingOrder) return; // Prevent multiple simultaneous rejects
    
    setState(() {
      isRejectingOrder = true;
    });

    try {
      print('🚫 Controller - Starting reject process for order $orderID');
      
      final result = await orderRepo.rejectOrderWithId(orderID);

      if (result['success']) {
        print('✅ Controller - Order $orderID rejected successfully');
        
        // Remove the order from pending list
        setState(() {
          pendingOrdersModel.removeWhere((order) => order.orderId.toString() == orderID);
          isRejectingOrder = false;
        });

        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.cancel, color: Colors.orange, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🚫 تم رفض الطلب',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'طلب #$orderID - تم إشعار العميل بالرفض',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange[600],
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        // Refresh orders list
        await refreshOrders();
      } else {
        print('❌ Failed to reject order $orderID: ${result['message']}');
        setState(() {
          isRejectingOrder = false;
        });
        
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '❌ فشل في رفض الطلب',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        result['message'] ?? 'خطأ غير معروف',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error rejecting order $orderID: $e');
      setState(() {
        isRejectingOrder = false;
      });
      
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🌐 خطأ في الاتصال',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'تحقق من اتصال الإنترنت وحاول مرة أخرى',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[600],
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
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

  // إضافة دالة تحديث الطلبات
  Future<void> refreshOrders() async {
    print('🔄 Controller - Refreshing orders list');
    listenForOrders();
  }
}
