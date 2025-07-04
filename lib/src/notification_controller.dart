// import 'dart:async';
// import 'dart:isolate';
// import 'dart:ui';

// // import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'repository/settings_repository.dart' as settingRepo;

// ///  *********************************************
// ///     NOTIFICATION CONTROLLER
// ///  *********************************************
// ///
// class NotificationController {
//   static ReceivedAction? initialAction;

//   ///  *********************************************
//   ///     INITIALIZATIONS
//   ///  *********************************************
//   ///
//   static Future<void> initializeLocalNotifications() async {
//     await AwesomeNotifications().initialize(
//       null, //'resource://drawable/res_app_icon',//
//       [
//         NotificationChannel(
//           channelKey: 'alerts',
//           channelName: 'Alerts',
//           channelDescription: 'Notification tests as alerts',
//           playSound: true,
//           onlyAlertOnce: true,
//           groupAlertBehavior: GroupAlertBehavior.Children,
//           importance: NotificationImportance.High,
//           defaultPrivacy: NotificationPrivacy.Private,
//           defaultColor: Colors.deepPurple,
//           ledColor: Colors.deepPurple,
//         ),
//       ],
//       debug: true,
//     );

//     // Get initial notification action is optional
//     initialAction = await AwesomeNotifications().getInitialNotificationAction(
//       removeFromActionEvents: false,
//     );
//   }

//   static late ReceivePort receivePort;

//   static Future<void> initializeIsolateReceivePort() async {
//     receivePort = ReceivePort(
//       'Notification action port in main isolate',
//     )..listen((silentData) => onActionReceivedImplementationMethod(silentData));

//     // This initialization only happens on main isolate
//     IsolateNameServer.registerPortWithName(
//       receivePort.sendPort,
//       'notification_action_port',
//     );
//   }

//   ///  *********************************************
//   ///     NOTIFICATION EVENTS LISTENER
//   ///  *********************************************
//   ///  Notifications events are only delivered after call this method
//   static Future<void> startListeningNotificationEvents() async {
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: onActionReceivedMethod,
//     );
//   }

//   ///  *********************************************
//   ///     NOTIFICATION EVENTS
//   ///  *********************************************
//   ///
//   @pragma('vm:entry-point')
//   static Future<void> onActionReceivedMethod(
//     ReceivedAction receivedAction,
//   ) async {
//     if (receivedAction.actionType == ActionType.SilentAction ||
//         receivedAction.actionType == ActionType.SilentBackgroundAction) {
//       // For background actions, you must hold the execution until the end
//       print(
//         'Message sent via notification input: "${receivedAction.buttonKeyInput}"',
//       );
//       await executeLongTaskInBackground();
//     } else {
//       // this process is only necessary when you need to redirect the user
//       // to a new page or use a valid context, since parallel isolates do not
//       // have valid context, so you need redirect the execution to main isolate
//       if (receivePort == null) {
//         print(
//           'onActionReceivedMethod was called inside a parallel dart isolate.',
//         );
//         SendPort? sendPort = IsolateNameServer.lookupPortByName(
//           'notification_action_port',
//         );

//         if (sendPort != null) {
//           print('Redirecting the execution to main isolate process.');
//           sendPort.send(receivedAction);
//           return;
//         }
//       }

//       return onActionReceivedImplementationMethod(receivedAction);
//     }
//   }

//   static Future<void> onActionReceivedImplementationMethod(
//     ReceivedAction receivedAction,
//   ) async {
//     // Navigator.pushNamed(
//     //     settingRepo.navigatorKey.currentstate!.context, '/orderNotification',
//     //     arguments: receivedAction.payload);
//   }

//   ///  *********************************************
//   ///     REQUESTING NOTIFICATION PERMISSIONS
//   ///  *********************************************
//   ///
//   static Future<bool> displayNotificationRationale() async {
//     bool userAuthorized = false;
//     BuildContext context = settingRepo.navigatorKey.currentContext!;
//     await showDialog(
//       context: context,
//       builder: (BuildContext ctx) {
//         return AlertDialog(
//           title: Text(
//             'Get Notified!',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Image.asset(
//                       'assets/images/animated-bell.gif',
//                       height: MediaQuery.of(context).size.height * 0.3,
//                       fit: BoxFit.fitWidth,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Allow Awesome Notifications to send you beautiful notifications!',
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(ctx).pop();
//               },
//               child: Text(
//                 'Deny',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleLarge?.copyWith(color: Colors.red),
//               ),
//             ),
//             TextButton(
//               onPressed: () async {
//                 userAuthorized = true;
//                 Navigator.of(ctx).pop();
//               },
//               child: Text(
//                 'Allow',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleLarge?.copyWith(color: Colors.deepPurple),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//     return userAuthorized &&
//         await AwesomeNotifications().requestPermissionToSendNotifications();
//   }

//   ///  *********************************************
//   ///     BACKGROUND TASKS TEST
//   ///  *********************************************
//   static Future<void> executeLongTaskInBackground() async {
//     print("starting long task");
//     await Future.delayed(const Duration(seconds: 4));
//     final url = Uri.parse("http://google.com");
//     final re = await http.get(url);
//     print(re.body);
//     print("long task done");
//   }

//   ///  *********************************************
//   ///     NOTIFICATION CREATION METHODS
//   ///  *********************************************
//   ///nnotii
//   static Future<void> createNewNotification(RemoteMessage message) async {
//     bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
//     if (!isAllowed) isAllowed = await displayNotificationRationale();
//     if (!isAllowed) return;

//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: -1,
//         // -1 is replaced by a random number
//         channelKey: 'alerts',
//         title: message.data['title'],
//         body: message.data['body'],
//         largeIcon: message.data['icon'],
//         notificationLayout: NotificationLayout.Default,
//         payload: {'orderId': message.data['order_id']},
//       ),
//     );
//   }

//   /// Get FCM device token
//   static Future<void> getDeviceToken() async {
//     try {
//       String? token = await FirebaseMessaging.instance.getToken();
//       if (token != null) {
//         print('🔑 FCM Token: $token');
//         // You can send this token to your backend or save it
//       } else {
//         print('❌ Failed to get FCM token');
//       }
//     } catch (e) {
//       print('❌ Error getting FCM token: $e');
//     }
//   }

//   static Future<void> resetBadgeCounter() async {
//     await AwesomeNotifications().resetGlobalBadge();
//   }

//   static Future<void> cancelNotifications() async {
//     await AwesomeNotifications().cancelAll();
//   }
// }

import 'dart:async';
import 'dart:isolate';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'repository/settings_repository.dart' as settingRepo;

class NotificationController {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static late AndroidNotificationChannel channel;

  static ReceivePort? receivePort;

  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationResponse,
    );

    channel = const AndroidNotificationChannel(
      'alerts', // id
      'Alerts', // title
      description: 'Notification alerts',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> onNotificationResponse(
    NotificationResponse response,
  ) async {
    final payload = response.payload;
    if (payload != null) {
      // Use this to navigate to specific screen
      // Navigator.pushNamed(settingRepo.navigatorKey.currentContext!, '/orderNotification', arguments: payload);
      print('Notification clicked with payload: $payload');
    }
  }

  static Future<void> displayNotificationRationale() async {
    BuildContext context = settingRepo.navigatorKey.currentContext!;
    bool userAuthorized = false;

    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Get Notified!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/animated-bell.gif',
                      height: MediaQuery.of(context).size.height * 0.3,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Allow notifications to keep you updated!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Deny', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                userAuthorized = true;
                Navigator.of(ctx).pop();
              },
              child: Text('Allow', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );

    if (userAuthorized) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> createNewNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'alerts',
          'Alerts',
          channelDescription: 'Notification alerts',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: message.data['order_id'],
    );
  }

  static Future<void> getDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('🔑 FCM Token: $token');
      } else {
        print('❌ Failed to get FCM token');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  static Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final response = await http.get(url);
    print(response.body);
    print("long task done");
  }
}
