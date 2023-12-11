import Cocoa
import FlutterMacOS

public class FlutterDesktopSleepPlugin: NSObject, FlutterPlugin {
    var methodChannel: FlutterMethodChannel?
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlutterDesktopSleepPlugin()
    let channel = FlutterMethodChannel(name: "flutter_desktop_sleep", binaryMessenger: registrar.messenger)
    instance.methodChannel=channel;
    instance.applicationDidFinishLaunching2()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func applicationShouldTerminate(_ controller: FlutterViewController) -> NSApplication.TerminateReply {       
        let notificationChannel = FlutterMethodChannel(name: "flutter_desktop_sleep",
                                                       binaryMessenger: controller.engine.binaryMessenger)
        let reason = NSAppleEventManager.shared()
            .currentAppleEvent?
            .attributeDescriptor(forKeyword: kAEQuitReason)

        switch reason?.enumCodeValue {
        case kAELogOut, kAEReallyLogOut:
            NSLog("Logout")
            notificationChannel.invokeMethod("onWindowsSleep", arguments: "terminate_app")
            return .terminateLater
        case kAERestart, kAEShowRestartDialog:
            NSLog("Restart")
            return .terminateNow
        case kAEShutDown, kAEShowShutdownDialog:
            NSLog("Shutdown")
            notificationChannel.invokeMethod("onWindowsSleep", arguments: "terminate_app")
            return .terminateNow
        case 0:
            // `enumCodeValue` docs:
            //
            //    The contents of the descriptor, as an enumeration type,
            //    or 0 if an error occurs.
            NSLog("We don't know")
            notificationChannel.invokeMethod("onWindowsSleep", arguments: "terminate_app")
            return .terminateNow
        default:
            NSLog("Cmd-Q, Quit menu item, ...")
            notificationChannel.invokeMethod("onWindowsSleep", arguments: "terminate_app")
            return .terminateNow
        }
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
   case "terminateWindow":
                  NSLog("Going to close app")
                  DispatchQueue.main.async {
                      NSApp.reply(toApplicationShouldTerminate: true)
                  }
                  result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }



    public func applicationDidFinishLaunching2() {

          NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                            name: NSWorkspace.willSleepNotification, object: nil)
          NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                            name: NSWorkspace.didWakeNotification, object: nil)

      }

      @objc public func sleepListener(_ aNotification: Notification) {

          if aNotification.name == NSWorkspace.willSleepNotification {
              methodChannel?.invokeMethod("onWindowsSleep", arguments: "sleep")
              NSLog("Going to sleep")
          } else if aNotification.name == NSWorkspace.didWakeNotification {
               methodChannel?.invokeMethod("onWindowsSleep", arguments: "woke_up")
              NSLog("Woke up")
          } else {
              NSLog("Some other event other than the first two")
          }
      }

}
