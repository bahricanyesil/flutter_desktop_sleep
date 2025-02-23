import Cocoa
import FlutterMacOS
import flutter_desktop_sleep

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  var _windowManager = FlutterDesktopSleepPlugin()
  override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    return _windowManager.applicationShouldTerminate(controller);
  }
}
