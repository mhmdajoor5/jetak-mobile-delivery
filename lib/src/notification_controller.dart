import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repository/settings_repository.dart' as settingRepo;
import 'repository/orders/pending_order_repo.dart' as pendingRepo;
import 'repository/user_repository.dart' as userRepo;
import 'models/pending_order_model.dart';

class NotificationController {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static late AndroidNotificationChannel channel;
  static late AudioPlayer _audioPlayer;
  static Timer? _orderCheckTimer;
  static List<String> _notifiedOrderIds = [];
  static bool _isCheckingOrders = false;

  static ReceivePort? receivePort;

  static Future<void> initializeLocalNotifications() async {
    try {
      // تهيئة مشغل الصوت
      _audioPlayer = AudioPlayer();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: DarwinInitializationSettings(
              requestAlertPermission: true,
              requestBadgePermission: true,
              requestSoundPermission: true,
              requestCriticalPermission: false,
            ),
          );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationResponse,
      );

      channel = const AndroidNotificationChannel(
        'alerts', // id
        'Alerts', // title
        description: 'Notification alerts for new orders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // بدء فحص الطلبات الجديدة
      await startOrderChecking();

      print('✅ Notification system initialized successfully');
    } catch (e) {
      print('⚠️ Error initializing notifications: $e');
      print('⚠️ App will continue without notifications');
      // Don't rethrow - allow app to continue
    }
  }

  /// بدء فحص دوري للطلبات الجديدة
  static Future<void> startOrderChecking() async {
    print('🔔 Starting automatic new order checking...');
    
    // إلغاء أي timer موجود
    _orderCheckTimer?.cancel();
    
    // تحميل قائمة الطلبات المبلغ عنها من SharedPreferences
    await _loadNotifiedOrderIds();
    
    // بدء timer للفحص كل 30 ثانية
    _orderCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkForNewOrders();
    });
    
    // فحص فوري للطلبات الجديدة
    await _checkForNewOrders();
  }

  /// إيقاف فحص الطلبات الجديدة
  static void stopOrderChecking() {
    print('🔔 Stopping automatic new order checking...');
    _orderCheckTimer?.cancel();
    _orderCheckTimer = null;
  }

  /// فحص الطلبات الجديدة
  static Future<void> _checkForNewOrders() async {
    if (_isCheckingOrders) return; // منع التداخل في الطلبات
    
    _isCheckingOrders = true;
    
    try {
      final user = userRepo.currentUser.value;
      if (user.apiToken == null || user.id == null) {
        print('⚠️ User not authenticated, skipping order check');
        return;
      }

      print('🔍 Checking for new orders...');
      
      // الحصول على الطلبات المعلقة
      final response = await pendingRepo.getPendingOrders(
        driverId: user.id.toString(),
      );
      
      final parsedOrders = PendingOrdersModel.fromJson(response);
      
      print('📋 Found ${parsedOrders.orders.length} pending orders');
      
      // فحص الطلبات الجديدة (التي لم يتم إشعار عنها)
      for (final order in parsedOrders.orders) {
        final orderId = order.orderId.toString();
        
        if (!_notifiedOrderIds.contains(orderId)) {
          print('🔔 New order detected: $orderId');
          
          // إرسال إشعار للطلب الجديد
          await _sendNewOrderNotification(order);
          
          // إضافة الطلب لقائمة المبلغ عنها
          _notifiedOrderIds.add(orderId);
          await _saveNotifiedOrderIds();
        }
      }
      
      // تنظيف قائمة الطلبات المبلغ عنها (إزالة الطلبات التي لم تعد معلقة)
      final currentOrderIds = parsedOrders.orders.map((o) => o.orderId.toString()).toList();
      _notifiedOrderIds.removeWhere((id) => !currentOrderIds.contains(id));
      await _saveNotifiedOrderIds();
      
    } catch (e) {
      print('❌ Error checking for new orders: $e');
      rethrow;
    } finally {
      _isCheckingOrders = false;
    }
  }

  /// إرسال إشعار للطلب الجديد
  static Future<void> _sendNewOrderNotification(PendingOrderModel order) async {
    try {
      print('🔔 Sending notification for new order: ${order.orderId}');

      // تشغيل الصوت والاهتزاز
      await playNotificationSound();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'new_orders',
            'New Orders',
            channelDescription: 'Notifications for new delivery orders',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            // Using default system notification sound
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            color: Color(0xFF4CAF50),
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // Using default system notification sound
            interruptionLevel: InterruptionLevel.critical,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Build notification body from order data without emojis
      String notificationBody = '';
      if (order.customerName.isNotEmpty) {
        notificationBody += 'Customer: ${order.customerName}';
      }
      if (order.address.isNotEmpty) {
        if (notificationBody.isNotEmpty) notificationBody += '\n';
        notificationBody += 'Address: ${order.address}';
      }

      await flutterLocalNotificationsPlugin.show(
        order.orderId,
        'New Delivery Order',
        notificationBody.isNotEmpty ? notificationBody : 'You have a new order',
        platformChannelSpecifics,
        payload: order.orderId.toString(),
      );

      print('✅ Notification sent for order: ${order.orderId}');
    } catch (e) {
      print('⚠️ Error sending notification for order ${order.orderId}: $e');
      // Don't rethrow - allow app to continue
    }
  }

  /// تحميل قائمة الطلبات المبلغ عنها من SharedPreferences
  static Future<void> _loadNotifiedOrderIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds = prefs.getStringList('notified_order_ids');
      _notifiedOrderIds = savedIds ?? [];
      print('📋 Loaded ${_notifiedOrderIds.length} previously notified order IDs');
    } catch (e) {
      print('❌ Error loading notified order IDs: $e');
      _notifiedOrderIds = [];
    }
  }

  /// حفظ قائمة الطلبات المبلغ عنها في SharedPreferences
  static Future<void> _saveNotifiedOrderIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('notified_order_ids', _notifiedOrderIds);
      print('💾 Saved ${_notifiedOrderIds.length} notified order IDs');
    } catch (e) {
      print('❌ Error saving notified order IDs: $e');
    }
  }

  static Future<void> onNotificationResponse(
    NotificationResponse response,
  ) async {
    // التعامل مع النقر على التنبيه
    if (response.payload != null) {
      print('🔔 Notification clicked with payload: ${response.payload}');
      
      // الانتقال لصفحة الطلبات المعلقة
      if (settingRepo.navigatorKey.currentState != null) {
        settingRepo.navigatorKey.currentState!.pushReplacementNamed(
          '/Pages',
          arguments: 1, // فهرس صفحة الطلبات
        );
      }
    }
  }

  static Future<void> requestPermissions() async {
    try {
      if (settingRepo.navigatorKey.currentContext == null) {
        print('⚠️ Navigator context is null, skipping permission request');
        return;
      }

      if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
          TargetPlatform.iOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
      } else if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
                 TargetPlatform.android) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }

      print('✅ Notification permissions requested');
    } catch (e) {
      print('⚠️ Error requesting notification permissions: $e');
      // Don't rethrow - allow app to continue
    }
  }

  static Future<void> playNotificationSound() async {
    try {
      // إضافة اهتزاز متعدد (للأندرويد)
      if (settingRepo.navigatorKey.currentContext != null &&
          Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
              TargetPlatform.android) {
        // اهتزاز قوي لجذب الانتباه
        await HapticFeedback.vibrate();
        await Future.delayed(Duration(milliseconds: 200));
        await HapticFeedback.vibrate();
        await Future.delayed(Duration(milliseconds: 200));
        await HapticFeedback.vibrate();
      }

      print('🔊 تم تشغيل صوت التنبيه');
    } catch (e) {
      print('⚠️ خطأ في تشغيل صوت التنبيه: $e');
      // Don't rethrow - allow app to continue
    }
  }

  static Future<void> createNewNotification(RemoteMessage message) async {
    try {
      // تشغيل الصوت أولاً
      await playNotificationSound();

      final notification = message.notification;
      if (notification == null) return;

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'alerts',
            'Alerts',
            channelDescription: 'Notification alerts for new orders',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            // Using default system notification sound
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            color: Color(0xFF2196F3),
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // Using default system notification sound
            interruptionLevel: InterruptionLevel.critical,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Use title and body directly from FCM notification object
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title ?? '',
        notification.body ?? '',
        platformChannelSpecifics,
        payload: message.data['order_id'],
      );

      print('🔔 Notification displayed: ${notification.title}');
    } catch (e) {
      print('⚠️ Error creating notification: $e');
      // Don't rethrow - allow app to continue
    }
  }

  static Future<void> getDeviceToken() async {
    try {
      print('🔑 Getting FCM Device Token from NotificationController...');
      
      if (Platform.isIOS) {
        String? apnsToken;
        int retries = 0;
        while (apnsToken == null && retries < 10) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            print('⏳ Waiting for APNS token (attempt ${retries + 1}/10)...');
            await Future.delayed(Duration(seconds: 2));
            retries++;
          }
        }
        print('📱 APNS Token retrieved: ${apnsToken != null ? "SUCCESS" : "FAILED"}');
      }
      
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

  /// إعادة تعيين قائمة الطلبات المبلغ عنها (للاختبار أو إعادة التشغيل)
  static Future<void> resetNotificationHistory() async {
    _notifiedOrderIds.clear();
    await _saveNotifiedOrderIds();
    print('🔄 Reset notification history');
  }

  /// مسح جميع بيانات الإشعارات المخزنة
  static Future<void> clearAllNotificationData() async {
    try {
      print('🗑️ Clearing all notification data...');

      // 1. Clear notified order IDs
      _notifiedOrderIds.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notified_order_ids');
      print('✅ Cleared notified order IDs');

      // 2. Clear FCM message ID
      await prefs.remove('google.message_id');
      print('✅ Cleared FCM message ID');

      // 3. Cancel all pending notifications
      await cancelNotifications();
      print('✅ Cancelled all notifications');

      print('✅ All notification data has been cleared successfully');
    } catch (e) {
      print('❌ Error clearing notification data: $e');
      rethrow;
    }
  }

  /// اختبار صوت الإشعار
  static Future<void> testNotificationSound() async {
    print('🧪 اختبار صوت التنبيه...');
    await playNotificationSound();
  }

  /// الحصول على إحصائيات الإشعارات
  static Map<String, dynamic> getNotificationStats() {
    return {
      'is_checking_active': _orderCheckTimer?.isActive ?? false,
      'notified_orders_count': _notifiedOrderIds.length,
      'notified_order_ids': _notifiedOrderIds,
      'is_currently_checking': _isCheckingOrders,
    };
  }

  static Future<void> executeLongTaskInBackground() async {
    // مهام إضافية في background
  }
}
