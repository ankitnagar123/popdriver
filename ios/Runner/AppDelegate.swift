import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    self.window?.backgroundColor = UIColor.white

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
      !mapsApiKey.isEmpty
    {
      GMSServices.provideAPIKey(mapsApiKey)
    }

    // Firebase is initialized from Dart (main.dart). Register plugins here so
    // firebase_messaging can hook APNS before Dart calls getToken (pop_user pattern).
    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    DispatchQueue.main.async {
      application.registerForRemoteNotifications()
    }
    return result
  }
}
