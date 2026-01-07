import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:convert';
import '../repository/user_repository.dart' as userRepo;
import '../repository/settings_repository.dart' as settingRepo;
import 'package:flutter/material.dart';

class PusherHelper {
  static PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  static bool _isInitialized = false;

  // Cache to prevent duplicate event processing
  static final Set<String> _processedOrders = {};
  static final Map<String, DateTime> _eventTimestamps = {};

  // Debounce duration (ignore events for same order within this time)
  static const Duration _debounceDuration = Duration(seconds: 5);

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
    print("📨 Channel: ${event.channelName} | User: ${event.userId}");
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

          // Extract order ID
          final String orderId = data['order_id']?.toString() ?? '';

          if (orderId.isEmpty) {
            print("⚠️ Order ID is missing in Pusher event, skipping...");
            return;
          }

          // Check if order is already processed (accepted/rejected)
          if (_processedOrders.contains(orderId)) {
            print("⏭️ Order $orderId already processed (accepted/rejected), ignoring duplicate event");
            return;
          }

          // Check if we received this event recently (debounce)
          if (_eventTimestamps.containsKey(orderId)) {
            final lastEvent = _eventTimestamps[orderId]!;
            final timeSinceLastEvent = DateTime.now().difference(lastEvent);

            if (timeSinceLastEvent < _debounceDuration) {
              print("⏭️ Debouncing event for order $orderId (last event ${timeSinceLastEvent.inSeconds}s ago)");
              return;
            }
          }

          // Update timestamp for this order
          _eventTimestamps[orderId] = DateTime.now();
          print("✅ Processing new order event for order $orderId");

          showNewOrderNotification(data);
        } else {
          print("ℹ️ Pusher event ignored (name not matched): ${event.eventName}");
        }
      } catch (e) {
        print("❌ Error in Pusher onEvent: $e");
      }
    });
  }

  static void showNewOrderNotification(Map<String, dynamic> data) {
    print("🖥️ Preparing to show notification screen...");
    print("🧾 Parsed notification data: $data");
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
        'restaurant': data['restaurant']?.toString() ?? '',
        'restaurant_latitude': data['restaurant_latitude'],
        'restaurant_longitude': data['restaurant_longitude'],
        'user': data['user']?.toString() ?? 'Customer',
        'total': data['total']?.toString() ?? '0.0',
        // status من الخادم، وإذا لم يصل نعرض Pending
        'status': data['status']?.toString() ?? 'Pending',
        'address': address,
        'description': description,
        'delivery_latitude': data['delivery_address']?['latitude'],
        'delivery_longitude': data['delivery_address']?['longitude'],
      };

      print("🧭 Navigation args map: $argsMap");
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

  /// Mark an order as processed (accepted or rejected)
  /// This prevents the same order from triggering notifications again
  static void markOrderAsProcessed(String orderId) {
    _processedOrders.add(orderId);
    print("✅ Order $orderId marked as processed");

    // Clean up old timestamps to prevent memory leaks
    _cleanupOldTimestamps();
  }

  /// Remove an order from the processed list
  /// Use this if you need to reprocess an order
  static void unmarkOrderAsProcessed(String orderId) {
    _processedOrders.remove(orderId);
    print("🔄 Order $orderId unmarked from processed list");
  }

  /// Clear all processed orders and timestamps
  /// Useful for testing or when starting a new session
  static void clearProcessedOrders() {
    _processedOrders.clear();
    _eventTimestamps.clear();
    print("🗑️ Cleared all processed orders and timestamps");
  }

  /// Clean up old timestamps to prevent memory leaks
  /// Removes timestamps older than 1 hour
  static void _cleanupOldTimestamps() {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(Duration(hours: 1));

    _eventTimestamps.removeWhere((orderId, timestamp) {
      final isOld = timestamp.isBefore(oneHourAgo);
      if (isOld) {
        print("🗑️ Removing old timestamp for order $orderId");
      }
      return isOld;
    });

    // Also limit the size of processed orders cache
    // Keep only the last 100 processed orders to prevent unlimited growth
    if (_processedOrders.length > 100) {
      final excess = _processedOrders.length - 100;
      final ordersToRemove = _processedOrders.take(excess).toList();
      _processedOrders.removeAll(ordersToRemove);
      print("🗑️ Removed $excess old processed orders from cache");
    }
  }
}
