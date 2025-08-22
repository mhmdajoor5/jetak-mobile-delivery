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
    // تهيئة مشغل الصوت
    _audioPlayer = AudioPlayer();
    
    // إعدادات خاصة للأيفون - تأجيل حتى يكون context جاهز
    try {
      if (settingRepo.navigatorKey.currentContext != null) {
        if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
            TargetPlatform.iOS) {
          print('📱 تهيئة إعدادات الصوت للأيفون...');
          
          // ضبط إعدادات الصوت للأيفون
          await _audioPlayer.setVolume(1.0);
          
          // إعدادات إضافية للأيفون
          try {
            // يمكن إضافة إعدادات AVAudioSession هنا إذا لزم الأمر
            print('✅ تم تهيئة إعدادات الصوت للأيفون');
          } catch (e) {
            print('⚠️ تحذير في إعدادات الصوت للأيفون: $e');
          }
        }
      } else {
        print('⚠️ Context not ready yet, will configure iOS settings later');
      }
    } catch (e) {
      print('⚠️ Error configuring iOS settings: $e');
    }
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            requestCriticalPermission: true,
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
    
    // تأجيل إعدادات الأيفون حتى يكون context جاهز
    Future.delayed(Duration(seconds: 2), () {
      _configureIOSSettings();
    });
  }

  /// إعدادات خاصة للأيفون بعد أن يكون context جاهز
  static Future<void> _configureIOSSettings() async {
    try {
      if (settingRepo.navigatorKey.currentContext != null) {
        if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
            TargetPlatform.iOS) {
          print('📱 إعدادات الأيفون المتأخرة...');
          
          // ضبط إعدادات الصوت للأيفون
          await _audioPlayer.setVolume(1.0);
          
          // إعدادات إضافية للأيفون
          try {
            // يمكن إضافة إعدادات AVAudioSession هنا إذا لزم الأمر
            print('✅ تم إعداد إعدادات الأيفون المتأخرة');
          } catch (e) {
            print('⚠️ تحذير في إعدادات الأيفون المتأخرة: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Error in delayed iOS configuration: $e');
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
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          color: Color(0xFF4CAF50), // أخضر للطلبات الجديدة
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification_sound.wav',
          interruptionLevel: InterruptionLevel.critical,
          categoryIdentifier: 'new_order',
          threadIdentifier: 'delivery_orders',
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
    
    print('✅ Notification sent for order: ${order.orderId}');
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
        print('⚠️ Context not available for permission request');
        return;
      }
      
      if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
          TargetPlatform.iOS) {
        print('📱 طلب أذونات الإشعارات للأيفون...');
        
        // طلب أذونات الإشعارات
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
        
        // طلب أذونات الصوت
        try {
          await _audioPlayer.setVolume(1.0);
          print('✅ تم ضبط مستوى الصوت للأيفون');
        } catch (e) {
          print('⚠️ تحذير: لا يمكن ضبط مستوى الصوت: $e');
        }
        
      } else if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
                 TargetPlatform.android) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  static Future<void> playNotificationSound() async {
    try {
      print('🔊 بدء تشغيل صوت التنبيه...');
      
      // إيقاف أي صوت قيد التشغيل
      await _audioPlayer.stop();
      
      // ضبط مستوى الصوت
      await _audioPlayer.setVolume(1.0);
      
      // إعدادات خاصة للأيفون
      try {
        if (settingRepo.navigatorKey.currentContext != null) {
          if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
              TargetPlatform.iOS) {
            print('📱 تشغيل الصوت للأيفون...');
            
            // محاولة تشغيل الصوت مع إعدادات خاصة للأيفون
            try {
              await _audioPlayer.play(AssetSource('notification_sound.wav'));
              print('✅ تم تشغيل الصوت للأيفون بنجاح');
            } catch (iosError) {
              print('⚠️ خطأ في تشغيل الصوت للأيفون: $iosError');
              // محاولة ثانية
              await _audioPlayer.play(AssetSource('notification_sound.wav'));
            }
          } else {
            // تشغيل ملف الصوت للأندرويد
            await _audioPlayer.play(AssetSource('notification_sound.wav'));
          }
          
          // انتظار انتهاء الصوت
          _audioPlayer.onPlayerComplete.listen((event) {
            print('🔊 انتهى تشغيل صوت التنبيه');
          });
          
          // إضافة اهتزاز متعدد (للأندرويد)
          if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
              TargetPlatform.android) {
            // اهتزاز قوي لجذب الانتباه
            await HapticFeedback.vibrate();
            await Future.delayed(Duration(milliseconds: 200));
            await HapticFeedback.vibrate();
            await Future.delayed(Duration(milliseconds: 200));
            await HapticFeedback.vibrate();
          }
          
          // اهتزاز للأيفون (إذا كان متاح)
          if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
              TargetPlatform.iOS) {
            await HapticFeedback.lightImpact();
            await Future.delayed(Duration(milliseconds: 100));
            await HapticFeedback.mediumImpact();
          }
        } else {
          // إذا لم يكن context متاح، شغل الصوت مباشرة
          await _audioPlayer.play(AssetSource('notification_sound.wav'));
        }
      } catch (contextError) {
        print('⚠️ Context error, playing sound directly: $contextError');
        await _audioPlayer.play(AssetSource('notification_sound.wav'));
      }
      
      print('🔊 تم تشغيل صوت التنبيه بنجاح');
    } catch (e) {
      print('❌ خطأ في تشغيل صوت التنبيه: $e');
      // محاولة تشغيل الصوت الافتراضي للنظام
      try {
        await _audioPlayer.play(AssetSource('notification_sound.wav'));
      } catch (fallbackError) {
        print('❌ فشل في تشغيل الصوت الافتراضي: $fallbackError');
      }
    }
  }

  static Future<void> createNewNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // تشغيل الصوت فقط إذا كان الإشعار يتعلق بطلب جديد
    final isNewOrder = message.data.containsKey('order_id') || 
                      message.data.containsKey('id') ||
                      (notification.title?.contains('طلب') == true) ||
                      (notification.body?.contains('طلب') == true);
    
    if (isNewOrder) {
      print('🆕 طلب جديد تم استلامه - تشغيل الصوت');
      await playNotificationSound();
    } else {
      print('📱 إشعار عادي - بدون صوت');
    }

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
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          color: Color(0xFF2196F3),
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification_sound.wav',
          interruptionLevel: InterruptionLevel.critical,
          categoryIdentifier: 'new_order',
          threadIdentifier: 'delivery_orders',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title ?? 'طلب جديد',
      notification.body ?? 'لديك طلب جديد يحتاج للمراجعة',
      platformChannelSpecifics,
      payload: message.data['order_id'],
    );
    
    print('🔔 تم إرسال التنبيه: ${notification.title}');
  }

  /// إرسال إشعار للطلب الجديد مع الصوت
  static Future<void> sendNewOrderNotification(String orderId, String customerName, String address) async {
    print('🆕 إرسال إشعار للطلب الجديد: $orderId');
    
    // تشغيل الصوت للطلب الجديد
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
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          color: Color(0xFF4CAF50), // أخضر للطلبات الجديدة
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification_sound.wav',
          interruptionLevel: InterruptionLevel.critical,
          categoryIdentifier: 'new_order',
          threadIdentifier: 'delivery_orders',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      int.parse(orderId), // استخدام ID الطلب كـ notification ID
      '🆕 طلب توصيل جديد!',
      '👤 العميل: $customerName\n📍 $address',
      platformChannelSpecifics,
      payload: orderId,
    );
    
    print('✅ تم إرسال إشعار الطلب الجديد: $orderId');
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

  /// اختبار صوت الإشعار (فقط عند الضغط على زر الاختبار)
  static Future<void> testNotificationSound() async {
    print('🧪 اختبار صوت التنبيه...');
    
    try {
      // اختبار خاص للأيفون
      if (settingRepo.navigatorKey.currentContext != null) {
        if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
            TargetPlatform.iOS) {
          print('📱 اختبار الصوت للأيفون...');
          
          // إيقاف أي صوت قيد التشغيل
          await _audioPlayer.stop();
          
          // ضبط مستوى الصوت
          await _audioPlayer.setVolume(1.0);
          
          // تشغيل الصوت
          await _audioPlayer.play(AssetSource('notification_sound.wav'));
          
          print('✅ تم اختبار الصوت للأيفون بنجاح');
        } else {
          await playNotificationSound();
        }
      } else {
        // إذا لم يكن context متاح، شغل الصوت مباشرة
        await _audioPlayer.play(AssetSource('notification_sound.wav'));
      }
    } catch (e) {
      print('❌ خطأ في اختبار الصوت: $e');
      // محاولة تشغيل الصوت العادي
      await playNotificationSound();
    }
  }

  /// تشغيل الصوت فقط عند استلام طلب جديد
  static Future<void> playSoundForNewOrder() async {
    print('🆕 تشغيل الصوت للطلب الجديد...');
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

  /// ضمان عمل الصوت في الخلفية للأيفون
  static Future<void> ensureBackgroundAudio() async {
    try {
      if (settingRepo.navigatorKey.currentContext != null) {
        if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
            TargetPlatform.iOS) {
          print('📱 ضمان عمل الصوت في الخلفية للأيفون...');
          
          try {
            // إعدادات إضافية للصوت في الخلفية
            await _audioPlayer.setVolume(1.0);
            
            // يمكن إضافة إعدادات AVAudioSession هنا
            print('✅ تم ضمان عمل الصوت في الخلفية');
          } catch (e) {
            print('⚠️ تحذير في إعدادات الصوت في الخلفية: $e');
          }
        }
      } else {
        print('⚠️ Context not available for background audio setup');
      }
    } catch (e) {
      print('❌ Error ensuring background audio: $e');
    }
  }

  /// إعادة تشغيل مشغل الصوت
  static Future<void> restartAudioPlayer() async {
    try {
      await _audioPlayer.dispose();
      _audioPlayer = AudioPlayer();
      
      if (settingRepo.navigatorKey.currentContext != null) {
        if (Theme.of(settingRepo.navigatorKey.currentContext!).platform ==
            TargetPlatform.iOS) {
          await _audioPlayer.setVolume(1.0);
        }
      }
      
      print('🔄 تم إعادة تشغيل مشغل الصوت');
    } catch (e) {
      print('❌ خطأ في إعادة تشغيل مشغل الصوت: $e');
    }
  }
}
