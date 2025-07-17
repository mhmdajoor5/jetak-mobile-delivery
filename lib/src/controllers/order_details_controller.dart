import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../models/order_status_history.dart';
import '../repository/order_repository.dart';

class OrderDetailsController extends ControllerMVC {
  Order? order;
  OrderStatusHistory? orderStatusHistory;
  late GlobalKey<ScaffoldState> scaffoldKey;

  OrderDetailsController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void listenForOrder({String? id, String? message}) async {
    if (id == null || id.isEmpty) {
      print('⚠️ Warning: Order ID is null or empty');
      return;
    }

    try {
      final Stream<Order> stream = await getOrder(id);
      stream.listen(
        (Order order) {
          setState(() => order = order);
          // Load detailed status history after order is loaded
          loadOrderStatusHistory(id);
        },
        onError: (a) {
          print('❌ Error loading order: $a');
          if (scaffoldKey.currentContext != null) {
            ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(state!.context).verify_your_internet_connection,
                ),
              ),
            );
          }
        },
        onDone: () {
          if (message != null && scaffoldKey.currentContext != null) {
            ScaffoldMessenger.of(
              scaffoldKey.currentContext!,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
      );
    } catch (e) {
      print('❌ Error in listenForOrder: $e');
    }
  }

  Future<void> loadOrderStatusHistory(String orderId) async {
    try {
      print('🔄 Loading detailed status history for order: $orderId');
      final history = await getOrderStatusHistory(orderId);
      if (history != null) {
        setState(() {
          orderStatusHistory = history;
        });
        print('✅ Order status history loaded: ${history.statusHistory.length} status changes');
      }
    } catch (e) {
      print('❌ Error loading order status history: $e');
    }
  }

  Future<void> refreshOrder() async {
    if (order?.id != null) {
      orderStatusHistory = null; // Clear existing history
      listenForOrder(
        id: order!.id,
        message: S.of(state!.context).order_refreshed_successfuly,
      );
    }
  }

  void doOnTheWayOrder(Order order) async {
    onTheWayOrder(order).then((value) {
      setState(() {
        order.orderStatus?.id = '4';
      });
      // Reload status history after status change
      if (order.id != null) {
        loadOrderStatusHistory(order.id!);
      }
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('The order is On The Way to the client')),
      );
    });
  }

  void doDeliveredOrder(Order order) async {
    deliveredOrder(order).then((value) {
      setState(() {
        order.orderStatus?.id = '5';
      });
      // Reload status history after status change
      if (order.id != null) {
        loadOrderStatusHistory(order.id!);
      }
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('The order deliverd successfully to client')),
      );
    });
  }
}
