import UIKit
import Flutter
import GoogleMaps
import Firebase
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // add your google maps key
    GMSServices.provideAPIKey("AIzaSyBKRGQo3RI12eALPEz0ji4DxvCgq6VaZdA")
    FirebaseApp.configure() //add this before the code below
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

}
