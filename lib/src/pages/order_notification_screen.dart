import 'dart:convert';

import 'package:deliveryboy/src/models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:audioplayers/audioplayers.dart';

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

  String audioasset = "notification_sound.wav";

  @override
  void initState() {
    play();
    super.initState();
  }

  @override
  void dispose() {
    stopSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final args = (widget.routeArgument as Map<String, dynamic>)["message"];
    final argsMap = json.decode(args as String);
    print("argsMap: $argsMap");
    // final orderID = args.payload["offrderId"];
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          height: config.App(context).appHeight(110),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Positioned(
                top: 0,
                child: Container(
                  width: config.App(context).appWidth(100),
                  height: config.App(context).appHeight(29.5),
                  decoration: BoxDecoration(color: Colors.black54),
                ),
              ),
              Positioned(
                top: config.App(context).appHeight(29.5) - 140,
                child: SizedBox(
                  width: config.App(context).appWidth(84),
                  height: config.App(context).appHeight(29.5),
                  child: Text(
                    "You have a new order!",
                    style: Theme.of(context).textTheme.displaySmall!.merge(
                      TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: config.App(context).appHeight(29.5) - 50,
                child: Container(
                  height: size.height * 0.80,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 27),
                  width: config.App(context).appWidth(88),
                  child: Form(
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        Text(
                          argsMap['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        SizedBox(height: 16),
                        Text(
                          argsMap['text'],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.merge(TextStyle(color: Colors.black54)),
                        ),
                        Expanded(child: SizedBox()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: BlockButtonWidget(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                text: Text(
                                  "Reject",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.red,
                                onPressed: () async {
                                  try {
                                    // إيقاف الصوت أولاً
                                    stopSound();
                                    
                                    // await _con.scc(orderID);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "The order #${argsMap['id']} was rejected",
                                        ),
                                      ),
                                    );

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
                            SizedBox(width: 8),
                            Expanded(
                              child: BlockButtonWidget(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                text: Text(
                                  "Accept",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black54),
                                ),
                                color: Colors.green,
                                onPressed: () async {
                                  try {
                                    // إيقاف الصوت أولاً
                                    stopSound();
                                    
                                    print("argsMap['id']: ${argsMap['id']}");
                                    // await _con.acceptOrder(argsMap['id']);
                                    _con.acceptOrder(argsMap['id']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "The order #${argsMap['id']} was accepted",
                                        ),
                                      ),
                                    );
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/Pages',
                                      (Route<dynamic> route) => false,
                                    );
                                    Navigator.of(context).pushNamed(
                                      '/OrderDetails',
                                      arguments: RouteArgument(
                                        id: argsMap['id'],
                                      ),
                                    );
                                  } catch (e) {
                                    print("Err: $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 128),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void play() async {
    try {
      print('🔊 تشغيل صوت إشعار الطلب...');
      
      // إنشاء AudioPlayer جديد
      _audioPlayer = AudioPlayer();
      
      // إيقاف أي صوت قيد التشغيل
      await _audioPlayer!.stop();
      
      // ضبط مستوى الصوت
      await _audioPlayer!.setVolume(1.0);
      
      // تشغيل ملف الصوت
      await _audioPlayer!.play(AssetSource(audioasset));
      
      // تكرار الصوت حتى يتم الرد على الطلب
      _audioPlayer!.onPlayerComplete.listen((event) {
        // إعادة تشغيل الصوت مرة أخرى
        _audioPlayer!.play(AssetSource(audioasset));
      });
      
      print('🔊 تم تشغيل صوت إشعار الطلب بنجاح');
    } catch (e) {
      print('❌ خطأ في تشغيل صوت إشعار الطلب: $e');
    }
  }

  void stopSound() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        await _audioPlayer!.dispose();
        _audioPlayer = null;
        print('🔇 تم إيقاف صوت إشعار الطلب');
      }
    } catch (e) {
      print('❌ خطأ في إيقاف صوت إشعار الطلب: $e');
    }
  }
}
