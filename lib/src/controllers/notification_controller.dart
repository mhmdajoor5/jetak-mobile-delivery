import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/notification.dart' as model;
import '../repository/notification_repository.dart';

class NotificationController extends ControllerMVC {
  List<model.Notification> notifications = <model.Notification>[];
  int unReadNotificationsCount = 0;
  late GlobalKey<ScaffoldState> scaffoldKey;

  NotificationController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    listenForNotifications();
  }

  void listenForNotifications({String? message}) async {
    final Stream<model.Notification> stream = await getNotifications();
    stream.listen((model.Notification notification) {
      setState(() {
        notifications.add(notification);
      });
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (notifications.isNotEmpty) {
        unReadNotificationsCount = notifications.where((model.Notification n) => !n.read! ?? false).toList().length;
      } else {
        unReadNotificationsCount = 0;
      }
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshNotifications() async {
    notifications.clear();
    listenForNotifications(message: S.of(state!.context).notifications_refreshed_successfuly);
  }

  void doMarkAsReadNotifications(model.Notification notification) async {
    markAsReadNotifications(notification).then((value) {
      setState(() {
        --unReadNotificationsCount;
        notification.read = !notification.read!;
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text('This notification has marked as read'),
      ));
    });
  }

  void doMarkAsUnReadNotifications(model.Notification notification) {
    markAsReadNotifications(notification).then((value) {
      setState(() {
        ++unReadNotificationsCount;
        notification.read = !notification.read!;
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text('This notification has marked as un read'),
      ));
    });
  }

  void doRemoveNotification(model.Notification notification) async {
    removeNotification(notification).then((value) {
      setState(() {
        if (!notification.read!) {
          --unReadNotificationsCount;
        }
        notifications.remove(notification);
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text('Notification was removed'),
      ));
    });
  }
}
