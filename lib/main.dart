// // import 'package:awesome_notifications/awesome_notifications.dart';
import 'src/notification_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'src/helpers/intercom_helper.dart';
import 'src/helpers/FirebaseUtils.dart';

import 'generated/l10n.dart';
import 'route_generator.dart';
import 'src/helpers/app_config.dart' as config;
import 'src/helpers/custom_trace.dart';
import 'src/models/setting.dart';
import 'src/repository/settings_repository.dart' as settingRepo;
import 'src/repository/user_repository.dart' as userRepo;
// This must be a top-level function, outside of any class.
// It is called when the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in your background handlers,
  // such as Firestore, make sure to call `initializeApp` before using them.
  await Firebase.initializeApp();

  print('');
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║  🔔 BACKGROUND MESSAGE HANDLER CALLED (FROM MAIN.DART)       ║');
  print('╚═══════════════════════════════════════════════════════════════╝');
  print('📬 Message ID: ${message.messageId}');
  print('📬 Sent Time: ${message.sentTime}');
  print('📬 From: ${message.from}');
  print('');
  print('🔔 Notification Object:');
  if (message.notification != null) {
    print('   ✅ Has notification object (GOOD - iOS can handle this)');
    print('   📝 Title: ${message.notification!.title}');
    print('   📝 Body: ${message.notification!.body}');
    print('   🍎 Apple: ${message.notification!.apple}');
    print('   🤖 Android: ${message.notification!.android}');
  } else {
    print('   ❌ NO notification object (BAD - iOS will reject in background!)');
    print('   ⚠️  This is likely why notifications don\'t appear in background!');
  }
  print('');
  print('📦 Data Payload:');
  if (message.data.isNotEmpty) {
    print('   ✅ Has data: ${message.data}');
    message.data.forEach((key, value) {
      print('   - $key: $value');
    });
  } else {
    print('   ℹ️  No data payload');
  }
  print('');
  print('🔧 Message Category: ${message.category}');
  print('🔧 Content Available: ${message.contentAvailable}');
  print('🔧 Message Type: ${message.messageType}');
  print('╚═══════════════════════════════════════════════════════════════╝');
  print('');

  // Call your NotificationController to create a local notification
  NotificationController.createNewNotification(message);
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");
  await Firebase.initializeApp();

  // Initialize Intercom
  await IntercomHelper.initialize();

  // Login unidentified user for Intercom (for visitors/guests)
  await IntercomHelper.loginUnidentifiedUser();

  // Setup FCM token refresh listener early (before getting token)
  print('🚀 Setting up FCM token refresh listener at app startup...');
  FirebaseUtil.setupTokenRefreshListener();

  await NotificationController.getDeviceToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationController.initializeLocalNotifications();

  // Clear all notification data (remove this line after running once)
  await NotificationController.clearAllNotificationData();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    // Test notification removed - notifications will come from Backend/Firebase only
    // NotificationController.createNewNotification(
    //   RemoteMessage(
    //     senderId: "123456789",
    //     messageId: "619045",
    //     data: {"key": "value", 'order_id': "123"},
    //     notification: RemoteNotification(
    //       title: "Test Notification",
    //       body: "This is a test notification",
    //     ),
    //   ),
    // );

    settingRepo.initSettings();
    settingRepo.getCurrentLocation();
    userRepo.getCurrentUser();
    
    // Set Hebrew as default language if not already set
    if (settingRepo.setting.value.mobileLanguage.value.languageCode != 'he') {
      settingRepo.setting.value.mobileLanguage.value = Locale('he', '');
      settingRepo.setDefaultLanguage('he');
      // Force rebuild to apply language change
      settingRepo.setting.notifyListeners();
    }
    // NotificationController.startListeningNotificationEvents();

    // Listen to messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 onMessage: ${message.notification?.title}');
      showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 App opened from notification: ${message.data}');
    });
    super.initState();
  }

  void showLocalNotification(RemoteMessage message) {
    // استخدام NotificationController لعرض التنبيه مع الصوت
    NotificationController.createNewNotification(message);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingRepo.setting,
      builder: (context, Setting setting, _) {
        print(
          CustomTrace(StackTrace.current, message: setting.toMap().toString()),
        );
        Widget app = MaterialApp(
          navigatorKey: settingRepo.navigatorKey,
          title: setting.appName,
          initialRoute: '/Splash',
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
          locale: setting.mobileLanguage.value,
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme:
              setting.brightness.value == Brightness.light
                  ? ThemeData(
                    fontFamily: 'Poppins',
                    primaryColor: Colors.white,
                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                      elevation: 0,
                      foregroundColor: Colors.white,
                    ),
                    brightness: Brightness.light,
                    scaffoldBackgroundColor: Colors.white,
                    // accentColor: config.Colors().mainColor(1),
                    dividerColor: config.Colors().accentColor(0.1),
                    focusColor: config.Colors().accentColor(1),
                    hintColor: config.Colors().secondColor(1),
                    textTheme: TextTheme(
                      // headline5: TextStyle(
                      //     fontSize: 20.0,
                      //     color: config.Colors().secondColor(1),
                      //     height: 1.35),
                      // headline4: TextStyle(
                      //     fontSize: 18.0,
                      //     fontWeight: FontWeight.w600,
                      //     color: config.Colors().secondColor(1),
                      //     height: 1.35),
                      // headline3: TextStyle(
                      //     fontSize: 20.0,
                      //     fontWeight: FontWeight.w600,
                      //     color: config.Colors().secondColor(1),
                      //     height: 1.35),
                      // headline2: TextStyle(
                      //     fontSize: 22.0,
                      //     fontWeight: FontWeight.w700,
                      //     color: config.Colors().mainColor(1),
                      //     height: 1.35),
                      // headline1: TextStyle(
                      //     fontSize: 22.0,
                      //     fontWeight: FontWeight.w300,
                      //     color: config.Colors().secondColor(1),
                      //     height: 1.5),
                      // subtitle1: TextStyle(
                      //     fontSize: 15.0,
                      //     fontWeight: FontWeight.w500,
                      //     color: config.Colors().secondColor(1),
                      //     height: 1.35),
                      // headline6: TextStyle(
                      //     fontSize: 16.0,
                      //     fontWeight: FontWeight.w600,
                      //     color: config.Colors().mainColor(1),
                      //     height: 1.35),
                      // bodyText2: TextStyle(
                      //     fontSize: 12.0,
                      //     color: config.Colors().secondColor(1),
                      //     height: 1.35),
                      // bodyText1: TextStyle(
                      //     fontSize: 14.0,
                      //     color: config.Colors().secondColor(1),
                      //     height: 1.35),
                      // caption: TextStyle(
                      //     fontSize: 12.0,
                      //     color: config.Colors().accentColor(1),
                      //     height: 1.35),
                    ),
                  )
                  : ThemeData(
                    fontFamily: 'Poppins',
                    primaryColor: Color(0xFF252525),
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Color(0xFF2C2C2C),
                    // accentColor: config.Colors().mainDarkColor(1),
                    dividerColor: config.Colors().accentColor(0.1),
                    hintColor: config.Colors().secondDarkColor(1),
                    focusColor: config.Colors().accentDarkColor(1),
                    textTheme: TextTheme(
                      // headline5: TextStyle(
                      //     fontSize: 20.0,
                      //     color: config.Colors().secondDarkColor(1),
                      //     height: 1.35),
                      // headline4: TextStyle(
                      //     fontSize: 18.0,
                      //     fontWeight: FontWeight.w600,
                      //     color: config.Colors().secondDarkColor(1),
                      //     height: 1.35),
                      // headline3: TextStyle(
                      //     fontSize: 20.0,
                      //     fontWeight: FontWeight.w600,
                      //     color: config.Colors().secondDarkColor(1),
                      //     height: 1.35),
                      // headline2: TextStyle(
                      //     fontSize: 22.0,
                      //     fontWeight: FontWeight.w700,
                      //     color: config.Colors().mainDarkColor(1),
                      //     height: 1.35),
                      // headline1: TextStyle(
                      //     fontSize: 22.0,
                      //     fontWeight: FontWeight.w300,
                      //     color: config.Colors().secondDarkColor(1),
                      //     height: 1.5),
                      // subtitle1: TextStyle(
                      //     fontSize: 15.0,
                      //     fontWeight: FontWeight.w500,
                      //     color: config.Colors().secondDarkColor(1),
                      //     height: 1.35),
                      // headline6: TextStyle(
                      //     fontSize: 16.0,
                      //     fontWeight: FontWeight.w600,
                      //     color: config.Colors().mainDarkColor(1),
                      //     height: 1.35),
                      // bodyText2: TextStyle(
                      //     fontSize: 12.0,
                      //     color: config.Colors().secondDarkColor(1),
                      //     height: 1.35),
                      // bodyText1: TextStyle(
                      //     fontSize: 14.0,
                      //     color: config.Colors().secondDarkColor(1),
                      //     height: 1.35),
                      // caption: TextStyle(
                      //     fontSize: 12.0,
                      //     color: config.Colors().secondDarkColor(0.6),
                      //     height: 1.35),
                    ),
                  ),
        );

        // Global tap-to-dismiss keyboard wrapper
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: app,
        );
      },
    );
  }
}

// // // TODO: Define the background message handler
// // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// //   await Firebase.initializeApp();

// //   _showNotificationWithButton(message);

// //   if (kDebugMode) {
// //     print("Handling a background message: ${message.messageId}");
// //     print('Message data: ${message.data}');
// //     print('Message notification: ${message.notification?.title}');
// //     print('Message notification: ${message.notification?.body}');
// //   }
// // }

// void _showNotificationWithButton(RemoteMessage message) {
//   NotificationController.createNewNotification(message);
// }
