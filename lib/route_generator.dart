import 'package:flutter/material.dart';

import 'src/models/route_argument.dart';
import 'src/pages/complete_your_profile.dart';
import 'src/pages/debug.dart';
import 'src/pages/forget_password.dart';
import 'src/pages/help.dart';
import 'src/pages/languages.dart';
import 'src/pages/login.dart';
import 'src/pages/map.dart';
import 'src/pages/notifications.dart';
import 'src/pages/order.dart';
import 'src/pages/order_notification_screen.dart';
import 'src/pages/pages.dart';
import 'src/pages/settings.dart';
import 'src/pages/signup/signup.dart';
import 'src/pages/signup/CarryContractWidget.dart';
import 'src/pages/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/Splash':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/orderNotification':
        return MaterialPageRoute(builder: (_) => OrderNotificationScreen(routeArgument: args,));
      case '/SignUp':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/MobileVerification':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/MobileVerification2':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/Login':
        return MaterialPageRoute(builder: (_) => LoginWidget());
      case '/ForgetPassword':
        return MaterialPageRoute(builder: (_) => ForgetPasswordWidget());
      case '/Pages':
        return MaterialPageRoute(builder: (_) => PagesTestWidget(currentTab: args));
      case '/OrderDetails':
        return MaterialPageRoute(builder: (_) => OrderWidget(routeArgument: args as RouteArgument));
      case '/Notifications':
        return MaterialPageRoute(builder: (_) => NotificationsWidget());
      case '/Languages':
        return MaterialPageRoute(builder: (_) => LanguagesWidget());
      case '/Help':
        return MaterialPageRoute(builder: (_) => HelpWidget());
      case '/Settings':
        return MaterialPageRoute(builder: (_) => SettingsWidget());
      case '/Complete-profile':
        return MaterialPageRoute(builder: (_) => CompleteYourProfileWidget());
      case '/CarryContract':
        return MaterialPageRoute(builder: (_) => CarryContractWidget());
      case '/OrderTracking':
        return MaterialPageRoute(builder: (_) => OrderTracking(
          routeArgument: args as RouteArgument,
          parentScaffoldKey: GlobalKey<ScaffoldState>(),
        ));
      case '/Debug':
        return MaterialPageRoute(builder: (_) => DebugScreen());
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return MaterialPageRoute(builder: (_) => Scaffold(body: SafeArea(child: Text('Route Error'))));
    }
  }
}
