import SceneKit
import QuartzCore

final class Board {
    let zPosition: CGFloat
    var nodes = [SCNNode]()

    init(zPosition: CGFloat) {
        self.zPosition = zPosition
    }
}
