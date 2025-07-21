import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../repository/order_repository.dart';
import '../repository/user_repository.dart';

class ProfileController extends ControllerMVC {
  User user = User();
  List<Order> recentOrders = [];
  late GlobalKey<ScaffoldState> scaffoldKey;

  ProfileController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    listenForUser();
  }

  void listenForUser() {
    userRepository.getCurrentUser().then((user) {
      setState(() {
        user = user;
      });
    });
  }

  void listenForRecentOrders({String? message}) async {
    final Stream<Order> stream = await getOrdersHistory();
    stream.listen((Order order) {
      setState(() {
        recentOrders.add(order);
      });
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshProfile() async {
    recentOrders.clear();
    user = User();
    listenForRecentOrders(message: S.of(state!.context).orders_refreshed_successfuly);
    listenForUser();
  }
}
