import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UIDevice.current.isBatteryMonitoringEnabled = true

    if let controller = window?.rootViewController as? FlutterViewController {
      let batteryChannel = FlutterMethodChannel(
        name: "background_location_tracker/battery",
        binaryMessenger: controller.binaryMessenger
      )

      batteryChannel.setMethodCallHandler { call, result in
        if call.method == "getBatteryPercentage" {
          let level = UIDevice.current.batteryLevel
          result(level < 0 ? nil : Int(level * 100))
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
