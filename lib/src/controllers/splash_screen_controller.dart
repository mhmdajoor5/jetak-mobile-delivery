import 'dart:async';
import 'dart:convert';
import 'dart:io';

// // import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:global_configuration/global_configuration.dart';

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
    Timer(Duration(seconds: 12), () async {
      final context = scaffoldKey.currentContext;
      if (context != null) {
        // Load user data from SharedPreferences first
        await userRepo.getCurrentUser();
        
        // Check if user is authenticated
        if(userRepo.currentUser.value.auth == null) {
          // User is not authenticated, go to login
          Navigator.of(context).pushReplacementNamed('/Login');
        } else {
          // Double check user status from server
          try {
            final response = await http.get(
              Uri.parse('${GlobalConfiguration().getValue('api_base_url')}users/profile?api_token=${userRepo.currentUser.value.apiToken}'),
              headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            );
            
            if (response.statusCode == 200) {
              final userData = json.decode(response.body)['data'];
              final serverIsActive = userData['is_active'] ?? 1;
              
              print('🔍 Splash: Server isActive: $serverIsActive, Local isActive: ${userRepo.currentUser.value.isActive}');
              
              if (serverIsActive == 0) {
                // User is inactive on server, show contract page
                Navigator.of(context).pushReplacementNamed('/CarryContract');
              } else {
                // User is active, proceed to main app
                Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
              }
            } else {
              // If server check fails, use local data
              if (userRepo.currentUser.value.isActive == 0) {
                Navigator.of(context).pushReplacementNamed('/CarryContract');
              } else {
                Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
              }
            }
          } catch (e) {
            print('🔍 Splash: Error checking user status: $e');
            // If server check fails, use local data
            if (userRepo.currentUser.value.isActive == 0) {
              Navigator.of(context).pushReplacementNamed('/CarryContract');
            } else {
              Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
            }
          }
        }      
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(state!.context).verify_your_internet_connection),
          ),
        );
      }
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
