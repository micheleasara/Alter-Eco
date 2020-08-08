import SceneKit

/// Represents the controller for the virtual forest.
public class GameViewController: UIViewController {
    private let scene: SCNScene
    private let scnView = SCNView()
    private var floor: SCNNode!
    private var smog: SCNNode?
    
    // state used to move a node in edit mode
    private var movingNode: SCNNode?
    private var projectedInitialZ: CGFloat?
    private var lastPanLocation: SCNVector3?
    private var originalPosition: SCNVector3?
    private var nodeMoveGestureRecognizer: UIPanGestureRecognizer?
    
    // state used to add a new node
    private var nodeAddGestureRecognizer: UITapGestureRecognizer?
    private var urlNodeToLoad: URL?
    private var nodePlacedCallback: () -> Void = { }
    
    /// Initializes the game's scene with the scn file provided.
    public init(mainScenePath: String) {
        scene = SCNScene(named: mainScenePath)!
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Enables or disables the smog effect.
    public func isSmogOn(_ val: Bool) {
        if val {
            addGrayFilter()
            if smog == nil, let url = Bundle.main.url(forResource: "smog", withExtension: "scn", subdirectory: "art.scnassets") {
                smog = loadNode(fromFile: url, worldPosition: SCNVector3(0, 2, 0))
            }
            smog?.isHidden = false
        } else {
            scene.rootNode.filters = []
            smog?.removeFromParentNode()
            smog = nil
        }
    }
    
    /**
     Allows the user to place a node specified by the given scn filename and directory.
     - Parameter withFilename: name of the scn file containing the node.
     - Parameter inSubdirectory: resource subdirectory containing the file.
     - Parameter nodePlacedCallback: function to call when the user has finished placing the node.
     - Remark: If the node is not found, nothing happens. Also note that only one node at a time can be placed.
     */
    public func letUserPlaceNode(withFilename filename: String,
                                 inSubdirectory dir: String,
                                 nodePlacedCallback: @escaping () -> Void = {}) {
        guard urlNodeToLoad == nil else { return }
        urlNodeToLoad = Bundle.main.url(forResource: filename, withExtension: "scn", subdirectory: dir)
        let nodeAddGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addNewNodeByTouch(_:)))
        nodeAddGestureRecognizer.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(nodeAddGestureRecognizer)
        self.nodePlacedCallback = nodePlacedCallback
    }
    
    /// Enables or disables edit mode, allowing the user to move objects around with touch.
    public func isEditModeOn(_ val: Bool) {
        if val && nodeMoveGestureRecognizer == nil {
            nodeMoveGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveNodeByTouch(panGesture:)))
            scnView.addGestureRecognizer(nodeMoveGestureRecognizer!)
        } else {
            guard let recognizer = nodeMoveGestureRecognizer else { return }
            scnView.removeGestureRecognizer(recognizer)
            nodeMoveGestureRecognizer = nil
        }
    }
    
    /// Called after the controller's view is loaded into memory.
    public override func viewDidLoad() {
        super.viewDidLoad()
        scnView.scene = scene
        scnView.allowsCameraControl = true
        self.view = scnView
        
        setupNodes()
    }
    
    
    private func addGrayFilter() {
        if let grayFilter = CIFilter(name: "CIColorMonochrome") {
            grayFilter.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
            grayFilter.setValue(0.9, forKey: "inputIntensity")
            scene.rootNode.filters = [ grayFilter ]
        }
    }
    
    private func setupNodes() {
        floor = scene.rootNode.childNode(withName: "floor", recursively: false)!
        // TODO:- load from database
    }
    
    private func loadNode(fromFile url: URL, worldPosition: SCNVector3 = SCNVector3(0,0,0)) -> SCNReferenceNode? {
        if let referenceNode = SCNReferenceNode(url: url) {
            referenceNode.worldPosition = worldPosition
            scene.rootNode.addChildNode(referenceNode)
            SCNTransaction.begin()
            referenceNode.load()
            SCNTransaction.commit()
            return referenceNode
        }
        return nil
    }
    
    @objc
    private func addNewNodeByTouch(_ gesture: UITapGestureRecognizer) {
        if let url = urlNodeToLoad {
            let location = gesture.location(in: self.view)
            
            if let hitResult = scnView.hitTest(location, options: [SCNHitTestOption.ignoreHiddenNodes: true, SCNHitTestOption.firstFoundOnly: true]).first,
                hitResult.node == floor {
                // place object with a falling effect by using a y > 0
                let worldPos = SCNVector3(hitResult.worldCoordinates.x, 1.5, hitResult.worldCoordinates.z)
                _ = loadNode(fromFile: url, worldPosition: worldPos)
                
                // cleanup and callback
                if let recognizer = nodeMoveGestureRecognizer {
                    scnView.removeGestureRecognizer(recognizer)
                }
                urlNodeToLoad = nil
                nodePlacedCallback()
            }
        }
    }
    
    @objc private func moveNodeByTouch(panGesture: UIPanGestureRecognizer) {
        let location = panGesture.location(in: self.view)

        switch panGesture.state {
        case .began:
            selectMovableNode(atLocation: location)
        case .changed:
            moveSelectedNode(toLocation: location)
        case .ended:
            endNodeMoving()
        default:
            break
        }
    }
    
    private func selectMovableNode(atLocation: CGPoint) {
        let hitNodeResults = scnView.hitTest(atLocation, options: [SCNHitTestOption.ignoreHiddenNodes: true, SCNHitTestOption.firstFoundOnly: true])
        
        guard let movableHitResult = hitNodeResults.first, movableHitResult.node != floor
            else { return }
        projectedInitialZ = CGFloat(scnView.projectPoint(movableHitResult.worldCoordinates).z)
        lastPanLocation = movableHitResult.worldCoordinates
        movingNode = getTopNode(fromNode: movableHitResult.node)
        movingNode?.physicsBody?.isAffectedByGravity = false
        originalPosition = movableHitResult.node.worldPosition
    }
    
    private func getTopNode(fromNode node: SCNNode) -> SCNNode {
        var currentNode = node
        while let nextNode = node.parent, nextNode != currentNode {
            currentNode = nextNode
        }
        return currentNode
    }
    
    private func moveSelectedNode(toLocation: CGPoint) {
        guard let panStartZ = projectedInitialZ,
            let draggingNode = movingNode,
            let lastPanLocation = lastPanLocation else { return }

        let worldTouchPosition = scnView.unprojectPoint(SCNVector3(toLocation.x, toLocation.y, panStartZ))
        let movementVector = SCNVector3(worldTouchPosition.x - lastPanLocation.x,
                                        worldTouchPosition.y - lastPanLocation.y,
                                        worldTouchPosition.z - lastPanLocation.z)
        let movement = SCNAction.move(by: movementVector, duration: 0)
        draggingNode.runAction(movement)
        draggingNode.physicsBody?.velocity = SCNVector3(0,0,0)
        self.lastPanLocation = worldTouchPosition
    }
    
    private func endNodeMoving() {
        movingNode?.physicsBody?.isAffectedByGravity = true
        (projectedInitialZ, movingNode) = (nil, nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
