import 'dart:async';

// // import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/FirebaseUtils.dart';
import '../helpers/custom_trace.dart';
import '../notification_controller.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class SplashScreenController extends ControllerMVC {
  ValueNotifier<Map<String, double>> progress = ValueNotifier({});
  late GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  SplashScreenController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }

  @override
  void initState() async {
    super.initState();
    // FirebaseMessaging.instance
    //     .requestPermission(sound: true, badge: true, alert: true);

    firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // configureFirebase(firebaseMessaging);
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != '' &&
          settingRepo.setting.value.mainColor != null) {
        progress.value["Setting"] = 41;
        progress.notifyListeners();
      }
    });
    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        progress.value["User"] = 59;
        progress.notifyListeners();
      }
    });

    FirebaseUtil.registerFCM();
  
    try {
      await fcmOnLaunchListeners();
      await fcmOnResumeListeners();
      await fcmOnMessageListeners();
    } catch (e) {}
    Timer(Duration(seconds: 20), () {
      if(userRepo.currentUser.value.auth == null) {
        Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed('/Login');
      }      
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(S.of(state!.context).verify_your_internet_connection),
        ),
      );
    });
  }

  // void configureFirebase(FirebaseMessaging _firebaseMessaging) async  {
  //   try {
  //     await notificationOnResume;
  //     await       notificationOnLaunch;
  //     await notificationOnMessage();
  //     // _firebaseMessaging.configure(
  //     //   onMessage: notificationOnMessage,
  //     //   onLaunch: notificationOnLaunch,
  //     //   onResume: notificationOnResume,
  //     // );
  //   } catch (e) {
  //     print(CustomTrace(StackTrace.current, message: e.toString()));
  //     print(CustomTrace(StackTrace.current, message: 'Error Config Firebase'));
  //   }
  // }

  Future notificationOnResume(Map<String, dynamic> message) async {
    print(CustomTrace(StackTrace.current, message: message['data']['id']));
    try {
      if (message['data']['id'] == "orders") {
        settingRepo.navigatorKey.currentState?.pushReplacementNamed(
          '/Pages',
          arguments: 3,
        );
      } else if (message['data']['id'] == "messages") {
        settingRepo.navigatorKey.currentState?.pushReplacementNamed(
          '/Pages',
          arguments: 4,
        );
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Future notificationOnLaunch(Map<String, dynamic> message) async {
    String? messageId = await settingRepo.getMessageId();
    try {
      if (messageId != message['google.message_id']) {
        await settingRepo.saveMessageId(message['google.message_id']);
        if (message['data']['id'] == "orders") {
          settingRepo.navigatorKey.currentState?.pushReplacementNamed(
            '/Pages',
            arguments: 3,
          );
        } else if (message['data']['id'] == "messages") {
          settingRepo.navigatorKey.currentState?.pushReplacementNamed(
            '/Pages',
            arguments: 4,
          );
        }
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Future fcmOnMessageListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotificationWithButton(message);
    });
  }

  Future fcmOnLaunchListeners() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      String? messageId = await settingRepo.getMessageId();
      try {
        if (messageId != message.messageId) {
          await settingRepo.saveMessageId(message.messageId ?? "");
          if (message.data['id'] == "orders") {
            settingRepo.navigatorKey.currentState?.pushReplacementNamed(
              '/Pages',
              arguments: 2,
            );
          } else if (message.data['id'] == "messages") {
            settingRepo.navigatorKey.currentState?.pushReplacementNamed(
              '/Pages',
              arguments: 3,
            );
          }
        }
      } catch (e) {
        print(CustomTrace(StackTrace.current, message: e.toString()));
      }
    }
  }

  Future fcmOnResumeListeners() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(CustomTrace(StackTrace.current, message: message.data['id']));

      Navigator.pushNamed(
        settingRepo.navigatorKey.currentState!.context,
        '/orderNotification',
        arguments: message.data,
      );
      // try {
      //   if (message.data['id'] == "orders") {
      //     settingRepo.navigatorKey.currentState
      //         .pushReplacementNamed('/Pages', arguments: 2);
      //   } else if (message.data['id'] == "messages") {
      //     settingRepo.navigatorKey.currentState
      //         .pushReplacementNamed('/Pages', arguments: 3);
      //   }
      // } catch (e) {
      //   print(CustomTrace(StackTrace.current, message: e.toString()));
      // }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(CustomTrace(StackTrace.current, message: message.data['id']));

      Navigator.pushNamed(
        settingRepo.navigatorKey.currentState!.context,
        '/orderNotification',
        arguments: message.data,
      );
    });
  }

  void _showNotificationWithButton(RemoteMessage message) {
    print("_showNotificationWithButton");
    // AwesomeNotifications().createNotification(
    //   content: NotificationContent(
    //     category: NotificationCategory.Call,
    //     criticalAlert: true,
    //     id: 10,
    //     channelKey: 'alerts',
    //     title: message.data['title'],
    //     body: message.data['body'],
    //     largeIcon: message.data['icon'],
    //     notificationLayout: NotificationLayout.Default,
    //     payload: {'orderId': message.data['order_id']},
    //   ),
    // );
    NotificationController.createNewNotification(
      RemoteMessage(
        senderId: "123456789",
        messageId: "619045",
        data: {"key": "value", 'order_id': message.data['order_id']},
        notification: RemoteNotification(
          title: message.data['title'],
          body: message.data['body'],
        ),
      ),
    );
  }
}
