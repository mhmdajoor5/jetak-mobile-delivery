import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:convert';
import '../repository/user_repository.dart' as userRepo;
import '../repository/settings_repository.dart' as settingRepo;
import 'package:flutter/material.dart';

class PusherHelper {
  static PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  static bool _isInitialized = false;

  static Future<void> initPusher() async {
    if (userRepo.currentUser.value.id == null) {
      print("⚠️ Pusher: Cannot initialize, user ID is null");
      return;
    }

    if (_isInitialized) {
      print("⚠️ Pusher: Already initialized, skipping...");
      return;
    }

    try {
      print("🚀 Initializing Pusher (Public Channel) for driver: ${userRepo.currentUser.value.id}");
      
      await pusher.init(
        apiKey: "35debf4f355736840916",
        cluster: "ap2",
        onEvent: onEvent,
        onSubscriptionSucceeded: (channelName, data) {
          print("✅ Pusher: Subscribed to $channelName");
        },
        onSubscriptionError: (message, error) {
          print("❌ Pusher Subscription Error: $message");
          print("❌ Error Detail: $error");
        },
        onError: (message, code, error) {
          print("❌ Pusher Global Error: $message (code: $code)");
        },
        onConnectionStateChange: (currentState, previousState) {
          print("🔄 Pusher Connection State: $previousState -> $currentState");
        },
      );

      // التأكد من أن القناة عامة (driver.{id})
      final channelName = 'driver.${userRepo.currentUser.value.id}';
      print("📡 Subscribing to channel: $channelName");
      await pusher.subscribe(channelName: channelName);
      await pusher.connect();
      _isInitialized = true;
    } catch (e) {
      print("❌ Error initializing Pusher: $e");
    }
  }

  static void onEvent(PusherEvent event) {
    print("🔔 Received Pusher Event: ${event.eventName}");
    print("📋 Raw Event Data: ${event.data}");
    
    // تنفيذ الكود في إطار العمل الرئيسي لضمان ظهور الشاشة فوراً
    Future.delayed(Duration.zero, () {
      try {
        // التحقق من اسم الحدث (Laravel يرسله أحياناً بالاسم الكامل للفئة)
        if (event.eventName.contains('order.new') || 
            event.eventName.contains('NewOrderForDriver')) {
          
          final dynamic decoded = json.decode(event.data);
          Map<String, dynamic> data;
          
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          } else {
            print("⚠️ Pusher Data is not a Map, skipping...");
            return;
          }
          
          showNewOrderNotification(data);
        }
      } catch (e) {
        print("❌ Error in Pusher onEvent: $e");
          }
    });
  }

  static void showNewOrderNotification(Map<String, dynamic> data) {
    print("🖥️ Preparing to show notification screen...");
    if (settingRepo.navigatorKey.currentState != null) {
      
      // استخراج العنوان والملاحظات بشكل آمن
      String address = '';
      String description = '';
      
      if (data['delivery_address'] != null && data['delivery_address'] is Map) {
        address = data['delivery_address']['address']?.toString() ?? '';
        description = data['delivery_address']['description']?.toString() ?? '';
      }

      final Map<String, dynamic> argsMap = {
        'id': data['order_id']?.toString() ?? '',
        'title': 'New Order from ${data['restaurant'] ?? 'Restaurant'}',
        'user': data['user']?.toString() ?? 'Customer',
        'total': data['total']?.toString() ?? '0.0',
        'status': data['status']?.toString() ?? 'Pending',
        'address': address,
        'description': description,
      };

      print("🚀 Navigating to /orderNotification with ID: ${argsMap['id']}");
      
      settingRepo.navigatorKey.currentState!.pushNamed(
        '/orderNotification',
        arguments: {'message': json.encode(argsMap)},
      );
    } else {
      print("❌ Navigator state is null, cannot show notification screen");
    }
  }

  static Future<void> disconnect() async {
    try {
      await pusher.disconnect();
      _isInitialized = false;
      print("🔌 Pusher disconnected");
    } catch (e) {
      print("❌ Error disconnecting Pusher: $e");
    }
  }
}
