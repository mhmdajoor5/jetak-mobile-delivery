import 'dart:async';
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
      print('');
      print('═══════════════════════════════════════');
      print('🔔 Initializing Notification System');
      print('═══════════════════════════════════════');

      // تهيئة مشغل الصوت
      _audioPlayer = AudioPlayer();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      print('📋 Configuring iOS notification settings...');
      print('   - Request Alert Permission: true');
      print('   - Request Badge Permission: true');
      print('   - Request Sound Permission: true');
      print('   - Default Present Alert: true');
      print('   - Default Present Badge: true');
      print('   - Default Present Sound: true');

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: DarwinInitializationSettings(
              requestAlertPermission: true,
              requestBadgePermission: true,
              requestSoundPermission: true,
              requestCriticalPermission: false, // Requires special entitlement from Apple
              defaultPresentAlert: true,
              defaultPresentBadge: true,
              defaultPresentSound: true,
            ),
          );

      print('🔧 Initializing flutter_local_notifications plugin...');
      final bool? initialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationResponse,
      );
      print('✅ Plugin initialization result: $initialized');

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
      print('🔍 Starting periodic order checking...');
      await startOrderChecking();

      print('✅ Notification system initialized successfully');
      print('═══════════════════════════════════════');
      print('');
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
    if (_isCheckingOrders) {
      print('⏭️ Skipping check - already checking orders');
      return;
    }

    _isCheckingOrders = true;

    try {
      final user = userRepo.currentUser.value;
      if (user.apiToken == null || user.id == null) {
        print('⚠️ User not authenticated, skipping order check');
        return;
      }

      print('');
      print('🔍 ═══ Checking for new orders (${DateTime.now().toString().substring(11, 19)}) ═══');

      // الحصول على الطلبات المعلقة
      final response = await pendingRepo.getPendingOrders(
        driverId: user.id.toString(),
      );

      print('📦 API response received: ${response.toString().substring(0, response.toString().length > 100 ? 100 : response.toString().length)}...');

      late PendingOrdersModel parsedOrders;
      try {
        parsedOrders = PendingOrdersModel.fromJson(response);
      } catch (parseError) {
        print('❌ Error parsing orders response: $parseError');
        print('❌ Response was: $response');
        // Create empty model to continue
        parsedOrders = PendingOrdersModel(orders: []);
      }

      print('📋 Found ${parsedOrders.orders.length} total pending orders');
      print('📋 Already notified about ${_notifiedOrderIds.length} orders: $_notifiedOrderIds');

      int newOrdersCount = 0;

      // فحص الطلبات الجديدة (التي لم يتم إشعار عنها)
      for (final order in parsedOrders.orders) {
        final orderId = order.orderId.toString();

        if (!_notifiedOrderIds.contains(orderId)) {
          print('🆕 New order detected: #$orderId - ${order.customerName}');
          newOrdersCount++;

          // إرسال إشعار للطلب الجديد
          await _sendNewOrderNotification(order);

          // إضافة الطلب لقائمة المبلغ عنها
          _notifiedOrderIds.add(orderId);
          await _saveNotifiedOrderIds();

          print('✅ Order #$orderId added to notified list');
        } else {
          print('⏭️ Skipping order #$orderId - already notified');
        }
      }

      if (newOrdersCount == 0) {
        print('ℹ️ No new orders to notify about');
      } else {
        print('✅ Sent notifications for $newOrdersCount new order(s)');
      }

      // تنظيف قائمة الطلبات المبلغ عنها (إزالة الطلبات التي لم تعد معلقة)
      final currentOrderIds = parsedOrders.orders.map((o) => o.orderId.toString()).toList();
      final beforeCleanup = _notifiedOrderIds.length;
      _notifiedOrderIds.removeWhere((id) => !currentOrderIds.contains(id));
      final afterCleanup = _notifiedOrderIds.length;

      if (beforeCleanup != afterCleanup) {
        print('🧹 Cleaned up ${beforeCleanup - afterCleanup} completed/cancelled order(s) from tracking');
        await _saveNotifiedOrderIds();
      }

      print('═══════════════════════════════════════');
      print('');

    } catch (e, stackTrace) {
      print('❌ Error checking for new orders: $e');
      print('❌ Stack trace: $stackTrace');
      // DON'T rethrow - this would kill the periodic timer!
      // Just log the error and continue
    } finally {
      _isCheckingOrders = false;
    }
  }

  /// إرسال إشعار للطلب الجديد
  static Future<void> _sendNewOrderNotification(PendingOrderModel order) async {
    try {
      print('   🔔 Sending notification for order #${order.orderId}...');

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
            color: Color(0xFF4CAF50), // أخضر للطلبات الجديدة
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'notification_sound.wav',
            interruptionLevel: InterruptionLevel.timeSensitive,
            categoryIdentifier: 'NEW_ORDER_CATEGORY',
            threadIdentifier: 'new_orders',
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        order.orderId, // استخدام ID الطلب كـ notification ID
        '🆕 طلب توصيل جديد!',
        '👤 العميل: ${order.customerName}\n📍 ${order.address}',
        platformChannelSpecifics,
        payload: order.orderId.toString(),
      );

      print('   ✅ Notification displayed for order #${order.orderId}');
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
      print('📋 Requesting notification permissions...');

      if (settingRepo.navigatorKey.currentContext == null) {
        print('⚠️ Navigator context is null, skipping context-based permission request');
        print('⚠️ Permissions should have been requested during initialization');
        return;
      }

      if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
          TargetPlatform.iOS) {
        print('📱 Requesting iOS notification permissions...');
        final bool? result = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: false, // Don't request critical - requires special entitlement
            );
        print('✅ iOS notification permissions result: $result');

        // Check current permission status
        final IOSFlutterLocalNotificationsPlugin? iosPlugin =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();

        if (iosPlugin != null) {
          print('📋 Checking iOS notification permission status...');
        }
      } else if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
                 TargetPlatform.android) {
        print('🤖 Requesting Android notification permissions...');
        final bool? result = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        print('✅ Android notification permissions result: $result');
      }

      print('✅ Notification permissions requested');
    } catch (e) {
      print('⚠️ Error requesting notification permissions: $e');
      print('⚠️ Stack trace: ${StackTrace.current}');
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
            sound: 'notification_sound.wav',
            interruptionLevel: InterruptionLevel.timeSensitive,
            categoryIdentifier: 'FCM_ORDER_CATEGORY',
            threadIdentifier: 'fcm_orders',
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      print('📤 Attempting to show FCM notification with ID: ${notification.hashCode}');
      print('📤 Title: ${notification.title ?? 'طلب جديد'}');
      print('📤 Body: ${notification.body ?? 'لديك طلب جديد يحتاج للمراجعة'}');
      print('📤 iOS settings: presentAlert=true, presentSound=true, sound=notification_sound.wav');

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title ?? 'طلب جديد',
        notification.body ?? 'لديك طلب جديد يحتاج للمراجعة',
        platformChannelSpecifics,
        payload: message.data['order_id'],
      );

      print('✅ FCM notification show() completed: ${notification.title}');
      print('✅ If notification didn\'t appear, check iOS Settings > Notifications > Deliveryboy');
    } catch (e) {
      print('⚠️ Error creating notification: $e');
      // Don't rethrow - allow app to continue
    }
  }

  static Future<void> getDeviceToken() async {
    try {
      await FirebaseMessaging.instance.getAPNSToken();
      
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('🔑 FCM Token: $token');
        }
      } else {
        if (kDebugMode) {
          print('❌ Failed to get FCM token');
        }
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
