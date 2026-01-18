// // import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fcm_config/fcm_config.dart';

import 'src/notification_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'src/helpers/intercom_helper.dart';
import 'src/helpers/FirebaseUtils.dart';
import 'firebase_options.dart';

import 'generated/l10n.dart';
import 'route_generator.dart';
import 'src/helpers/app_config.dart' as config;
import 'src/helpers/custom_trace.dart';
import 'src/models/setting.dart';
import 'src/repository/settings_repository.dart' as settingRepo;
import 'src/repository/user_repository.dart' as userRepo;
// זו חייבת להיות פונקציה ברמה העליונה, מחוץ לכל מחלקה.
// היא נקראת כאשר האפליקציה ברקע או סגורה.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase מאותחל אוטומטית על ידי Flutter עבור מטפלי רקע
  // אל תקרא ל-Firebase.initializeApp() כאן כי זה גורם לשגיאת duplicate-app

  print('');
  print('╔═══════════════════════════════════════════════════════════════╗');
  print('║  🔔 מטפל הודעות רקע נקרא (מ-MAIN.DART)                      ║');
  print('╚═══════════════════════════════════════════════════════════════╝');
  print('📬 מזהה הודעה: ${message.messageId}');
  print('📬 זמן שליחה: ${message.sentTime}');
  print('📬 מאת: ${message.from}');
  print('');
  print('🔔 אובייקט התראה:');
  if (message.notification != null) {
    print('   ✅ יש אובייקט התראה (טוב - iOS יכול לטפל בזה)');
    print('   📝 כותרת: ${message.notification!.title}');
    print('   📝 תוכן: ${message.notification!.body}');
    print('   🍎 Apple: ${message.notification!.apple}');
    print('   🤖 Android: ${message.notification!.android}');
  } else {
    print('   ❌ אין אובייקט התראה (רע - iOS ידחה ברקע!)');
    print('   ⚠️  זו כנראה הסיבה שהתראות לא מופיעות ברקע!');
  }
  print('');
  print('📦 מטען נתונים:');
  if (message.data.isNotEmpty) {
    print('   ✅ יש נתונים: ${message.data}');
    message.data.forEach((key, value) {
      print('   - $key: $value');
    });
  } else {
    print('   ℹ️  אין מטען נתונים');
  }
  print('');
  print('🔧 קטגוריית הודעה: ${message.category}');
  print('🔧 תוכן זמין: ${message.contentAvailable}');
  print('🔧 סוג הודעה: ${message.messageType}');
  print('╚═══════════════════════════════════════════════════════════════╝');
  print('');

  // קרא ל-NotificationController כדי ליצור התראה מקומית
  NotificationController.createNewNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");

  // אתחול Firebase רק אם לא אותחל כבר
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('ℹ️ Firebase כבר אותחל, מדלג...');
    } else {
      rethrow; // זרוק שגיאות אחרות מחדש
    }
  }

  // רישום מטפל הודעות רקע פעם אחת בלבד באמצעות Firebase API הרשמי
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // אתחול FCM Config להתראות מקומיות בלבד (ללא מטפל רקע כפול)
  await FCMConfig.instance.init(
    // אל תעביר onBackgroundMessage כאן - כבר נרשם למעלה
    defaultAndroidForegroundIcon: '@mipmap/ic_launcher',
    defaultAndroidChannel: AndroidNotificationChannel(
      'high_importance_channel',
      'הגדרות Fcm',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    ),
  );

  // אתחול Intercom
  await IntercomHelper.initialize();

  // התחברות משתמש לא מזוהה ל-Intercom (למבקרים/אורחים)
  await IntercomHelper.loginUnidentifiedUser();

  // הגדרת מאזין רענון טוקן FCM מוקדם (לפני קבלת הטוקן)
  print('🚀 מגדיר מאזין רענון טוקן FCM בעת הפעלת האפליקציה...');
  FirebaseUtil.setupTokenRefreshListener();

  await NotificationController.getDeviceToken();
  await NotificationController.initializeLocalNotifications();

  // ניקוי כל נתוני ההתראות (הסר שורה זו לאחר הרצה אחת)
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

    settingRepo.initSettings();
    settingRepo.getCurrentLocation();
    userRepo.getCurrentUser();

    // הגדר עברית כשפת ברירת מחדל אם לא הוגדרה כבר
    if (settingRepo.setting.value.mobileLanguage.value.languageCode != 'he') {
      settingRepo.setting.value.mobileLanguage.value = Locale('he', '');
      settingRepo.setDefaultLanguage('he');
      // אילוץ בנייה מחדש כדי להחיל את שינוי השפה
      settingRepo.setting.notifyListeners();
    }
    // NotificationController.startListeningNotificationEvents();

    // האזן להודעות כאשר האפליקציה בחזית
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 onMessage: ${message.notification?.title}');
      showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 אפליקציה נפתחה מהתראה: ${message.data}');
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
                    ),
                  ),
        );

        // עטיפה גלובלית להסתרת מקלדת בלחיצה
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
