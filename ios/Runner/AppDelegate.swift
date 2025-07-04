import UIKit
import Flutter
import Firebase
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Initialize Firebase
    FirebaseApp.configure()

    // Provide your Google Maps API Key
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
