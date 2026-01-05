import Flutter
import UIKit
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
    GMSServices.provideAPIKey("AIzaSyC6GK6c5IMopZIMo_F1btLZgYY4HTIuPLg")

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("📱 APNs Token: \(token)")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // Handle notification when app is in FOREGROUND (iOS 10+)
  @available(iOS 10.0, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    print("═══════════════════════════════════════")
    print("📩 Notification received in FOREGROUND")
    print("═══════════════════════════════════════")
    print("Title: \(notification.request.content.title)")
    print("Body: \(notification.request.content.body)")
    print("UserInfo: \(userInfo)")
    print("═══════════════════════════════════════")

    // Show notification even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  // Handle notification tap (iOS 10+)
  @available(iOS 10.0, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    print("═══════════════════════════════════════")
    print("📲 Notification TAPPED by user")
    print("═══════════════════════════════════════")
    print("UserInfo: \(userInfo)")
    print("═══════════════════════════════════════")

    // Let Flutter handle the notification tap
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  // Handle silent/background notifications (for data-only messages)
  override func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    let state = application.applicationState
    var stateString = "UNKNOWN"

    switch state {
    case .active:
      stateString = "FOREGROUND/ACTIVE"
    case .inactive:
      stateString = "INACTIVE"
    case .background:
      stateString = "BACKGROUND"
    @unknown default:
      stateString = "UNKNOWN STATE"
    }

    print("═══════════════════════════════════════")
    print("📩 Remote Notification Received")
    print("═══════════════════════════════════════")
    print("App State: \(stateString)")
    print("UserInfo: \(userInfo)")
    print("═══════════════════════════════════════")

    // Call super to let Firebase Messaging handle it
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }
}
