import Cocoa

final class OverlayView: NSView {
    private let logoView = NSImageView()
    private var logoWidthConstraint: NSLayoutConstraint?

    private let dateTimeLabel = NSTextField(labelWithString: "")
    private var dateTimeWidthConstraint: NSLayoutConstraint?

    private let dateFormatter = DateFormatter()

    override var frame: NSRect {
        didSet {
            needsUpdateConstraints = true
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true

        logoView.wantsLayer = true
        logoView.image = NSImage(named: "logo")
        logoView.alphaValue = 0.7
        logoView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logoView)
        let logoWidthConstraint = logoView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            logoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            logoWidthConstraint,
            logoView.heightAnchor.constraint(equalTo: logoView.widthAnchor, multiplier: 9/16),])
        self.logoWidthConstraint = logoWidthConstraint

        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy, 'AT' h:mm a"

        dateTimeLabel.wantsLayer = true
        dateTimeLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2588235438, blue: 0.3058823645, alpha: 1)
        dateTimeLabel.alignment = .center
        dateTimeLabel.stringValue = dateFormatter.string(from: Date()).uppercased()
        dateTimeLabel.alphaValue = 0.7
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateTimeLabel)
        let dateTimeWidthConstraint = dateTimeLabel.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            dateTimeLabel.leadingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            dateTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            dateTimeWidthConstraint,])
        self.dateTimeWidthConstraint = dateTimeWidthConstraint
        dateTimeLabel.frameCenterRotation = 90

        let timer = Timer(fire: Date(timeIntervalSinceNow: 1), interval: 1, repeats: true) { _ in
            self.dateTimeLabel.stringValue = self.dateFormatter.string(from: Date()).uppercased()
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    override func updateConstraints() {
        super.updateConstraints()
        logoWidthConstraint?.constant = bounds.width / 8

        let fontName = "ArialNarrow-Bold"
        dateTimeLabel.font = NSFont(name: fontName, size: fontSizeToFit(width: abs(bounds.height / 2 - 20 * 2), text: dateTimeLabel.stringValue, font: NSFont(name: fontName, size: 300)!))
        dateTimeWidthConstraint?.constant = abs(bounds.height / 2 - 20 * 2)
    }

    func fontSizeToFit(width: CGFloat, text: String, font: NSFont) -> CGFloat {
        var w = bounds.height
        var fontSize: CGFloat = font.pointSize
        while w >= width {
            let boundingRect = NSAttributedString(string: text, attributes: [.font: NSFont(name: font.fontName, size: fontSize)!])
                .boundingRect(with: NSSize(width: CGFloat.greatestFiniteMagnitude, height: 0), options: [.usesLineFragmentOrigin])
            w = boundingRect.width
            fontSize -= 1
        }
        return fontSize
    }
}
