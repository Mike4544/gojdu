import UIKit
import Flutter
import FirebaseCore


func requestPermission() -> Void {
    let notificationsCenter = UNUserNotificationCenter.current()
    notificationsCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
        print("error while requesting permission: \(error.localizedDescription)")
        }
        if granted {
        print("permission granted")
        } else {
        print("permission denied")
        }
    }
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      if(FirebaseApp.app() == nil){
      FirebaseApp.configure()
      }
      
      if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        GeneratedPluginRegistrant.register(with: self)

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
      } else {
        let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }
    
      requestPermission()
      application.registerForRemoteNotifications()

      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
