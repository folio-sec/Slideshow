import Cocoa

final class PhotoLayer: CALayer {
    private let backgroundLayer = CALayer()
    let imageLayer = CALayer()
    private let titleLayer = CATextLayer()

    override init() {
        super.init()
        commonInit()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)

        backgroundLayer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        backgroundLayer.cornerRadius = 10
        backgroundLayer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        backgroundLayer.shadowRadius = 8
        backgroundLayer.shadowOpacity = 0.25
        backgroundLayer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundLayer.shouldRasterize = true

        addSublayer(backgroundLayer)

        imageLayer.contentsScale = 2
        imageLayer.contentsGravity = .resizeAspectFill
        imageLayer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        imageLayer.cornerRadius = 10
        imageLayer.masksToBounds = true
        backgroundLayer.addSublayer(imageLayer)

        titleLayer.contentsScale = 2
        titleLayer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        titleLayer.foregroundColor = #colorLiteral(red: 0.2549019754, green: 0.2588235438, blue: 0.3058823645, alpha: 1)
        titleLayer.alignmentMode = .right
        titleLayer.font = NSFont.boldSystemFont(ofSize: 52)
        titleLayer.fontSize = 52
        titleLayer.isWrapped = true
        titleLayer.truncationMode = .end

        backgroundLayer.addSublayer(titleLayer)
    }

    func setImage(_ image: NSImage) {
        imageLayer.contents = image
    }

    func setTitle(_ title: String) {
        titleLayer.string = title
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        let margin: CGFloat = 10

        var frame = bounds
        frame.origin = CGPoint(x: margin, y: margin)
        frame.size.width -= margin * 2
        frame.size.height -= margin * 2
        backgroundLayer.frame = frame

        frame = backgroundLayer.bounds
        frame.origin = CGPoint(x: margin, y: margin)
        frame.size.width -= margin
        frame.size.width -= margin

        frame.size.height = frame.size.width * (1 / 1.61803398875)
        frame.origin.y = backgroundLayer.bounds.height - frame.height - margin
        imageLayer.frame = frame

        titleLayer.frame = CGRect(x: frame.origin.x + margin, y: margin, width: frame.width - margin * 2, height: backgroundLayer.bounds.height - frame.height - margin * 3)
    }
}
