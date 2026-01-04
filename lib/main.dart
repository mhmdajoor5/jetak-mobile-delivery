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
  print('Handling a background message from main.dart: ${message.messageId}');
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

  // Setup FCM and notifications
  print('🚀 Setting up FCM and notifications...');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications first (requests permissions)
  await NotificationController.initializeLocalNotifications();

  // Then get FCM token (requires APNs token on iOS)
  await NotificationController.getDeviceToken();

  // Setup FCM token refresh listener
  FirebaseUtil.setupTokenRefreshListener();

  // Setup FCM message listeners for all app states
  _setupFCMListeners();

  runApp(MyApp());
}

/// Setup FCM listeners for foreground and notification tap events
void _setupFCMListeners() {
  print('🔔 Setting up FCM message listeners...');

  // Listen to messages when app is in FOREGROUND
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('');
    print('═══════════════════════════════════════');
    print('📩 FCM Message received (FOREGROUND)');
    print('═══════════════════════════════════════');
    print('📬 Title: ${message.notification?.title ?? 'No title'}');
    print('📬 Body: ${message.notification?.body ?? 'No body'}');
    print('📬 Data: ${message.data}');
    print('═══════════════════════════════════════');

    // Show local notification with sound
    NotificationController.createNewNotification(message);
  });

  // Listen when app is opened from a TERMINATED state via notification tap
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print('');
      print('═══════════════════════════════════════');
      print('📲 App opened from TERMINATED state via notification');
      print('═══════════════════════════════════════');
      print('📬 Title: ${message.notification?.title ?? 'No title'}');
      print('📬 Data: ${message.data}');
      print('═══════════════════════════════════════');

      // Handle navigation or other actions
      _handleNotificationTap(message);
    }
  });

  // Listen when app is opened from BACKGROUND state via notification tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('');
    print('═══════════════════════════════════════');
    print('📲 App opened from BACKGROUND via notification');
    print('═══════════════════════════════════════');
    print('📬 Title: ${message.notification?.title ?? 'No title'}');
    print('📬 Data: ${message.data}');
    print('═══════════════════════════════════════');

    // Handle navigation or other actions
    _handleNotificationTap(message);
  });

  print('✅ FCM message listeners setup complete');
}

/// Handle notification tap to navigate to relevant screen
void _handleNotificationTap(RemoteMessage message) {
  // Navigate to orders page if order_id is present
  if (message.data.containsKey('order_id')) {
    String? orderId = message.data['order_id'];
    print('🔔 Navigating to order: $orderId');

    // Use navigator key to navigate
    if (settingRepo.navigatorKey.currentState != null) {
      settingRepo.navigatorKey.currentState!.pushReplacementNamed(
        '/Pages',
        arguments: 1, // Index for orders page
      );
    }
  }
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
    super.initState();

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

    // FCM listeners are now set up in main() before runApp()
    // This ensures they catch all messages from app startup
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
