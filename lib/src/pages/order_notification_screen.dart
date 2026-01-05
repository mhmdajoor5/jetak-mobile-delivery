import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:deliveryboy/src/models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/order_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;

class OrderNotificationScreen extends StatefulWidget {
  final dynamic routeArgument;

  const OrderNotificationScreen({super.key, this.routeArgument});

  @override
  _OrderNotificationScreenState createState() =>
      _OrderNotificationScreenState();
}

class _OrderNotificationScreenState extends StateMVC<OrderNotificationScreen> {
  late OrderController _con;
  AudioPlayer? _audioPlayer;

  _OrderNotificationScreenState() : super(OrderController()) {
    _con = (controller as OrderController?)!;
  }

  @override
  void initState() {
    super.initState();
    _playNotificationSound();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _playNotificationSound() async {
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer?.play(AssetSource("notification_sound.wav"));
      _audioPlayer?.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print("❌ Error playing sound: $e");
    }
  }

  void _stopNotificationSound() {
    _audioPlayer?.stop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    Map<String, dynamic> argsMap = {};
    try {
      final args = (widget.routeArgument as Map<String, dynamic>)["message"];
      argsMap = json.decode(args as String);
    } catch (e) {
      print("❌ Error parsing notification args: $e");
    }

    final orderId = argsMap['id']?.toString() ?? '';
    final title = argsMap['title'] ?? 'New Order';
    final text = argsMap['text'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              config.Colors().mainColor(1),
              config.Colors().mainColor(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: config.Colors().mainColor(1),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "جديد! طلب جديد وصل",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Order #$orderId",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 40),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: BlockButtonWidget(
                        text: Text(
                          "Reject",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        color: Colors.redAccent,
                        onPressed: () async {
                          _stopNotificationSound();
                          try {
                            if (orderId.isNotEmpty) {
                              await _con.rejectOrder(orderId);
                            }
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/Pages',
                              (Route<dynamic> route) => false,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: BlockButtonWidget(
                        text: Text(
                          "Accept",
                          style: TextStyle(
                            color: config.Colors().mainColor(1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        color: Colors.white,
                        onPressed: () async {
                          _stopNotificationSound();
                          try {
                            if (orderId.isNotEmpty) {
                              await _con.acceptOrder(orderId);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/Pages',
                                (Route<dynamic> route) => false,
                              );
                              Navigator.of(context).pushNamed(
                                '/OrderDetails',
                                arguments: RouteArgument(id: orderId),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
