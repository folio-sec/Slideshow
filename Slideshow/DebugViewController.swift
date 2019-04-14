import Cocoa

final class DebugViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.subviews.forEach {
            $0.wantsLayer = true
            $0.layer?.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            $0.layer?.borderWidth = 4
        }
    }
}
