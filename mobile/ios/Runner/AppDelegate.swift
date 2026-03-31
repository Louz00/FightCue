import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let channelName = "fightcue/push_setup"
  private var apnsTokenHex: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard let self else {
          result(
            FlutterError(
              code: "push_unavailable",
              message: "Push bridge unavailable",
              details: nil
            )
          )
          return
        }

        switch call.method {
        case "getStatus":
          self.getPushStatus(result: result)
        case "requestPermission":
          self.requestPushPermission(application: application, result: result)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    apnsTokenHex = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    apnsTokenHex = nil
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  private func getPushStatus(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      result(self.buildPushPayload(from: settings))
    }
  }

  private func requestPushPermission(
    application: UIApplication,
    result: @escaping FlutterResult
  ) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
      DispatchQueue.main.async {
        application.registerForRemoteNotifications()
      }
      center.getNotificationSettings { settings in
        result(self.buildPushPayload(from: settings))
      }
    }
  }

  private func buildPushPayload(
    from settings: UNNotificationSettings
  ) -> [String: Any?] {
    [
      "permissionStatus": mapAuthorizationStatus(settings.authorizationStatus),
      "platform": "ios",
      "tokenValue": apnsTokenHex,
    ]
  }

  private func mapAuthorizationStatus(
    _ status: UNAuthorizationStatus
  ) -> String {
    switch status {
    case .authorized, .provisional, .ephemeral:
      return "granted"
    case .denied:
      return "denied"
    case .notDetermined:
      return "prompt"
    @unknown default:
      return "unknown"
    }
  }
}
