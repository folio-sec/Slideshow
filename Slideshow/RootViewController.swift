import Cocoa

final class RootViewController: NSViewController {
    let slideshowView = SlideshowView()
    let overlayView = OverlayView()
    let debugView = DebugViewController(nibName: nil, bundle: nil).view

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true

        slideshowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slideshowView)
        NSLayoutConstraint.activate([
            slideshowView.topAnchor.constraint(equalTo: view.topAnchor),
            slideshowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slideshowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            slideshowView.bottomAnchor.constraint(equalTo: view.bottomAnchor),])

        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),])

        #if DEBUG
        debugView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(debugView)
        NSLayoutConstraint.activate([
            debugView.topAnchor.constraint(equalTo: view.topAnchor),
            debugView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            debugView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            debugView.bottomAnchor.constraint(equalTo: view.bottomAnchor),])
        #endif

        let images = try! JSONDecoder().decode([Image].self, from: try! Foundation.Data(contentsOf: Bundle.main.url(forResource: "images", withExtension: "json")!))
        self.slideshowView.images = images
        self.slideshowView.startAnimation()
    }
}
