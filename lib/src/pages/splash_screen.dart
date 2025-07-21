// lib/views/splash_screen.dart (or wherever your UI file is)
import 'package:deliveryboy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/splash_screen_controller.dart';
import '../repository/user_repository.dart'; // Keep this import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  late SplashScreenController _con;

  SplashScreenState() : super(SplashScreenController()) {
    _con = (controller as SplashScreenController?)!;
  }

  @override
  void initState() {
    super.initState();
    _con.progress.addListener(_handleProgressUpdates);
  }

  void _handleProgressUpdates() {
    double totalProgress = 0; // Initialize total progress to 0
    for (var progress in _con.progress.value.values) {
      totalProgress += progress;
    }

    // Your original logic for navigation
    if (totalProgress >= 100) { // Changed from 59 to 100 for clarity based on your progress map values
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // Ensure the context is still valid before navigating
    if (!mounted) return;

    try {
      if (currentUser.value.apiToken == null) {
        Navigator.of(context).pushReplacementNamed('/Login');
      } else {
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
      }
    } catch (e) {
      // It's generally better to show an error message on the current screen
      // or handle this more gracefully, rather than just a snackbar that might disappear.
      // For a splash screen, if navigation fails due to internet,
      // you might want to show a retry button or a persistent error message.
      if (mounted) { // Check mounted again before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).verify_your_internet_connection),
        ));
      }
    }
  }

  @override
  void dispose() {
    _con.progress.removeListener(_handleProgressUpdates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents back button from closing the splash screen
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Optionally handle back button press if needed, e.g., show exit dialog
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        body: Container(
          // Using a more vibrant background might be appealing, or stick to theme
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor, // Example: Use primary color
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App Logo
                Hero( // Add Hero animation for smooth transition
                  tag: 'appLogo', // Unique tag for the logo
                  child: Image.asset(
                    'assets/img/logo.png',
                    width: 180, // Slightly larger logo
                    height: 180, // Maintain aspect ratio
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 40), // Adjusted spacing
                // App Title/Slogan (Optional)
                // Text(
                //   S.of(context).app_name, // Assuming you have an app name in S.of(context)
                //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                //         color: Colors.white, // White text for contrast
                //         fontWeight: FontWeight.bold,
                //       ),
                // ),
                SizedBox(height: 20),
                // Progress Indicator
                SizedBox(
                  width: 50, // Fixed width for circular progress indicator
                  height: 50, // Fixed height for circular progress indicator
                  child: CircularProgressIndicator(
                    strokeWidth: 4, // Thicker stroke for better visibility
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondary, // Use accent color
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Loading Text (Optional)
                Text(
                  S.of(context).welcome, // "Loading..." or similar
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.black38, // Slightly subdued text color
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}