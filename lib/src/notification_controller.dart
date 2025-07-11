import 'dart:async';
import 'dart:isolate';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
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

  static Future<void> playNotificationSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('notification_sound.wav'));
  }

  static Future<void> createNewNotification(RemoteMessage message) async {
    await playNotificationSound();
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
