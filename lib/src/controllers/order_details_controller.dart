import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class OrderDetailsController extends ControllerMVC {
  Order? order;
  late GlobalKey<ScaffoldState> scaffoldKey;

  OrderDetailsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForOrder({String? id, String? message}) async {
    if (id == null || id.isEmpty) {
      print('⚠️ Warning: Order ID is null or empty');
      return;
    }

    try {
      final Stream<Order> stream = await getOrder(id);
      stream.listen(
        (Order _order) {
          setState(() => order = _order);
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

  Future<void> refreshOrder() async {
    if (order?.id != null) {
      listenForOrder(
        id: order!.id,
        message: S.of(state!.context).order_refreshed_successfuly,
      );
    }
  }

  void doOnTheWayOrder(Order _order) async {
    onTheWayOrder(_order).then((value) {
      setState(() {
        this.order!.orderStatus?.id = '4';
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('The order is On The Way to the client')),
      );
    });
  }

  void doDeliveredOrder(Order _order) async {
    deliveredOrder(_order).then((value) {
      setState(() {
        this.order!.orderStatus?.id = '5';
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('The order deliverd successfully to client')),
      );
    });
  }
}
