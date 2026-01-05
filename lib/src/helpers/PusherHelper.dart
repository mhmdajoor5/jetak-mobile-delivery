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
      print("🚀 Initializing Pusher for driver: ${userRepo.currentUser.value.id}");
      
      await pusher.init(
        apiKey: "35debf4f355736840916",
        cluster: "ap2",
        onEvent: onEvent,
        authEndpoint: "https://carrytechnologies.co/broadcasting/auth",
        authParams: {
          'headers': {
            'Authorization': 'Bearer ${userRepo.currentUser.value.apiToken}',
            'Accept': 'application/json',
          }
        },
        onSubscriptionSucceeded: (channelName, data) {
          print("✅ Pusher: Subscribed to $channelName");
        },
        onSubscriptionError: (message, error, e) {
          print("❌ Pusher Subscription Error: $message");
        },
        onError: (message, code, e) {
          print("❌ Pusher Error: $message (code: $code)");
        },
        onConnectionStateChange: (currentState, previousState) {
          print("🔄 Pusher Connection State: $previousState -> $currentState");
        },
      );

      final channelName = 'private-driver.${userRepo.currentUser.value.id}';
      print("📡 Subscribing to channel: $channelName");
      await pusher.subscribe(channelName: channelName);
      await pusher.connect();
      _isInitialized = true;
      print("✅ Pusher connected successfully");
    } catch (e) {
      print("❌ Error initializing Pusher: $e");
    }
  }

  static void onEvent(PusherEvent event) {
    print("🔔 Received Pusher Event: ${event.eventName}");
    print("📋 Event Data: ${event.data}");

    if (event.eventName == 'order.new' || event.eventName == 'App\\Events\\NewOrderForDriver') {
      try {
        final data = json.decode(event.data);
        showNewOrderNotification(data);
      } catch (e) {
        print("❌ Error parsing Pusher event data: $e");
      }
    }
  }

  static void showNewOrderNotification(Map<String, dynamic> data) {
    print("🖥️ Showing New Order Notification Screen");
    
    // We use the navigatorKey from settingRepo to navigate from anywhere
    if (settingRepo.navigatorKey.currentState != null) {
      // Prepare the arguments in the format OrderNotificationScreen expects
      // argsMap['id'], argsMap['title'], argsMap['text']
      
      final Map<String, dynamic> argsMap = {
        'id': data['order_id']?.toString() ?? '',
        'title': 'New Order from ${data['restaurant'] ?? 'Restaurant'}',
        'text': 'User: ${data['user'] ?? 'Customer'}\nTotal: ${data['total'] ?? '0.0'}\nStatus: ${data['status'] ?? ''}',
      };

      settingRepo.navigatorKey.currentState!.pushNamed(
        '/orderNotification',
        arguments: {
          'message': json.encode(argsMap)
        },
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

