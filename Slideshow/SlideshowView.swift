import SceneKit
import QuartzCore

final class SlideshowView: SCNView {
    private let cameraNode = SCNNode()
    private var boards = [Board]()

    private let planeSize = CGSize(width: 30, height: 30)
    private let maxSceneSize = CGSize(width: 300, height: 300)

    var images: [Image] = [Image]() {
        didSet {
            setup()
        }
    }

    func startAnimation() {
        let level = 0
        let node = boards[level].nodes.near(from: .zero)
        node.scaleUp()
        cameraNode.pan(to: node.position) { [weak self] in
            guard let self = self else { return }
            self.loop(start: node, level: level)
        }
    }

    private func loop(start node: SCNNode, level: Int, wait: TimeInterval = 2) {
        let nextLevel = Int.random(in: 0..<3)
        let nextNode: SCNNode
        let nodes = boards[nextLevel].nodes
        if nextLevel == level {
            nextNode = nodes.far(from: node.position)
        } else {
            nextNode = nodes.near(from: node.position)
        }
        cameraNode.wait(wait) { [weak self] in
            guard let self = self else { return }

            node.resetScale()
            nextNode.scaleUp()

            self.randomCameraAction(node: nextNode) { [weak self] in
                guard let self = self else { return }
                self.loop(start: nextNode, level: nextLevel)
            }
        }
    }

    private func randomCameraAction(node: SCNNode, completion: @escaping () -> Void) {
        switch Int.random(in: 0...2) {
        case 0:
            self.cameraNode.yaw(to: node.position, angle: 0, completion: completion)
        case 1:
            var position = node.position
            position.x += 10
            self.cameraNode.yaw(to: position, angle: 15, completion: completion)
        case 2:
            var position = node.position
            position.x -= 10
            self.cameraNode.yaw(to: position, angle: -15, completion: completion)
        default:
            break
        }
    }

    private func setup() {
        scene = SCNScene()

        scene?.fogColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        scene?.fogStartDistance = 100
        scene?.fogEndDistance = 300

        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.camera?.zFar = 230
        cameraNode.position = SCNVector3(x: 0, y: 0, z: camera.zOffset)
        scene?.rootNode.addChildNode(cameraNode)

        for i in 0..<5 {
            boards.append(Board(zPosition: CGFloat(i) * -camera.zOffset))
        }

        for board in boards {
            for image in images.shuffled().prefix(50) {
                let layer = PhotoLayer()

                if let url = image.urls["regular"] {
                    ImagePipeline.shared.load(url, into: layer.imageLayer)
                }
                layer.setTitle(image.description ?? image.alt_description ?? "")

                let size = CGSize(width: planeSize.width * 1.5, height: planeSize.height * 1.5)
                if let point = randomPoint(size: size, in: board.nodes) {
                    let node = planeNode(layer: layer, position: SCNVector3(x: point.x, y: point.y, z: board.zPosition))
                    node.name = image.id
                    scene?.rootNode.addChildNode(node)

                    board.nodes.append(node)
                }
            }
        }

        backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.7294117647, blue: 0.7176470588, alpha: 1)
        #if DEBUG
        allowsCameraControl = true
        showsStatistics = true
        debugOptions = [.showCameras, .showBoundingBoxes, .showLightInfluences, .showLightExtents]
        #endif
    }

    private func planeNode(layer: CALayer, position: SCNVector3) -> SCNNode {
        let plane = SCNPlane(width: planeSize.width, height: planeSize.height)

        layer.frame = CGRect(x: 0, y: 0, width: plane.width * 2 * 10, height: plane.height * 2 * 10)
        plane.firstMaterial?.diffuse.contents = layer

        let node = SCNNode(geometry: plane)
        node.position = position

        return node
    }

    private func randomPoint(size: CGSize, in nodes: [SCNNode]) -> CGPoint? {
        for _ in 0..<5000 {
            let x = CGFloat.random(in: -maxSceneSize.width...(maxSceneSize.width / 2))
            let y = CGFloat.random(in: -maxSceneSize.height...(maxSceneSize.height / 2))
            let frame = CGRect(x: x, y: y, width: size.width, height: size.height)

            if nodes.isEmpty {
                return frame.origin
            } else {
                var intersects = false
                for node in nodes {
                    let position = node.position
                    let f = CGRect(x: position.x, y: position.y, width: size.width, height: size.height)
                    if f.intersects(frame) {
                        intersects = true
                    }
                }
                if !intersects {
                    return frame.origin
                }
            }
        }
        return nil
    }
}

private extension SCNCamera {
    var zOffset: CGFloat {
        return 70
    }
}

private extension SCNNode {
    func wait(_ duration: TimeInterval = 2, completion: @escaping () -> Void) {
        runAction(.wait(duration: duration)) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func pan(to position: SCNVector3, duration: TimeInterval = 2, completion: @escaping () -> Void) {
        var position = position
        position.z += camera?.zOffset ?? 0

        let action = SCNAction.move(to: position, duration: duration)
        action.timingMode = .linear
        action.timingFunction = {
            return simd_smoothstep(0, 1, $0)
        }

        runAction(action) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func yaw(to position: SCNVector3, angle: CGFloat = 10, duration: TimeInterval = 2, completion: @escaping () -> Void) {
        var position = position
        position.z += camera?.zOffset ?? 0

        let pan = SCNAction.move(to: position, duration: duration)
        pan.timingMode = .linear
        pan.timingFunction = {
            return simd_smoothstep(0, 1, $0)
        }

        let rotate = SCNAction.rotateTo(x: 0, y: angle * (CGFloat.pi / 180), z: 0, duration: 2)
        rotate.timingMode = .linear
        rotate.timingFunction = {
            return simd_smoothstep(0, 1, $0)
        }

        runAction(.group([pan, rotate])) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func zoomOut(duration: TimeInterval = 6, completion: @escaping () -> Void) {
        let rotate = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: duration)
        let move = SCNAction.move(to: SCNVector3(x: 0, y: 0, z: 160), duration: duration)
        runAction(.group([rotate, move]))

        runAction(.wait(duration: 2)) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func scaleUp(duration: TimeInterval = 2) {
        runAction(.scale(to: 1.8, duration: duration))
    }

    func resetScale(duration: TimeInterval = 2) {
        runAction(.scale(to: 1, duration: duration))
    }
}

private extension Array where Element: SCNNode {
    func near(from position: SCNVector3) -> Element  {
        return near(from: CGPoint(x: position.x, y: position.y))
    }

    func near(from point: CGPoint) -> Element  {
        return Array(sorted(from: point).dropFirst(4).prefix(6)).sample()
    }

    func far(from position: SCNVector3) -> Element  {
        return far(from: CGPoint(x: position.x, y: position.y))
    }

    func far(from point: CGPoint) -> Element  {
        return Array(sorted(from: point).dropFirst(16).prefix(6)).sample()
    }

    private func sample() -> Element {
        return self[Int.random(in: 0..<count)]
    }

    private func sorted(from point: CGPoint) -> [Element] {
        return sorted {
            let d1 = point.distance(to: CGPoint(x: $0.position.x, y: $0.position.y))
            let d2 = point.distance(to: CGPoint(x: $1.position.x, y: $1.position.y))
            return d1 < d2
        }
    }
}
