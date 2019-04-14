import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {}
}

final class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        if let main = NSScreen.main {
            window?.setFrame(main.visibleFrame, display: true, animate: true)
        }
    }
}

final class Window: NSWindow {
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return frameRect
    }
}
