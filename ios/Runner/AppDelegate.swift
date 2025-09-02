import UIKit
import Flutter
import UserNotifications
import GoogleMaps
import FirebaseCore
import FirebaseMessaging
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()

    // Configure Google Maps
    GMSServices.provideAPIKey("AIzaSyDR_QZaW3xiJfLLNFybEd6e6HunqDkUjJg")

    // Configure FCM
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self

    // Request notification permissions
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
      if let error = error {
        print("❌ Notification permission error: \(error)")
      } else {
        print("🔔 Notification permission granted: \(granted)")
      }
    }

    // Register for remote notifications
    application.registerForRemoteNotifications()

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Configure custom categories
    configureNotificationCategories()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - UNUserNotificationCenterDelegate

  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    print("FCM iOS: Foreground notification received")
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }

  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    print("FCM iOS: Notification tapped")
    let userInfo = response.notification.request.content.userInfo
    print("🔔 Notification data: \(userInfo)")
    completionHandler()
  }

  // MARK: - Notification Categories
  @available(iOS 10.0, *)
  private func configureNotificationCategories() {
    let viewAction = UNNotificationAction(
      identifier: "VIEW_ACTION",
      title: "View Details",
      options: [.foreground]
    )

    let dismissAction = UNNotificationAction(
      identifier: "DISMISS_ACTION",
      title: "Dismiss",
      options: []
    )

    let weddingCategory = UNNotificationCategory(
      identifier: "wedding_reminder",
      actions: [viewAction, dismissAction],
      intentIdentifiers: [],
      options: [.customDismissAction]
    )

    UNUserNotificationCenter.current().setNotificationCategories([weddingCategory])
    print("🔔 Notification categories configured")
  }

  // MARK: - MessagingDelegate
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("FCM iOS: Registration token received: \(fcmToken ?? "nil")")
    if let token = fcmToken {
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: ["token": token]
      )
    }
  }

  // MARK: - APNs Token
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("FCM iOS: APNs token received")
    Messaging.messaging().apnsToken = deviceToken
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("FCM iOS: Failed to register for remote notifications: \(error)")
  }
}
