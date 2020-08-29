import SceneKit

/// Represents the controller for the virtual forest.
public class GameViewController: UIViewController {
    /// The scene containing the virtual forest.
    private let scene: SCNScene
    /// The SCNView presented on screen.
    private let scnView = SCNView()
    /// A node representing the floor.
    private var floor: SCNNode!
    /// A node representing the smog effect.
    private var smog: SCNNode?
    /// Associates a node with a unique identifier which can be used to communicate with the database.
    private var nodeToUUID: Dictionary<SCNNode, String> = [:]
    /// Interacts with the database.
    private let DBMS: DBManager
    
    // state used to move a node in edit mode
    private var movingNode: SCNNode?
    private var projectedInitialZ: CGFloat?
    private var lastPanLocation: SCNVector3?
    private var originalPosition: SCNVector3?
    private var nodeMoveGestureRecognizer: UIPanGestureRecognizer?
    
    // state used to add a new node
    private var nodeAddGestureRecognizer: UITapGestureRecognizer?
    private var nodePlacedCallback: () -> Void = { }
    private var itemToPlace: ShopItem?
    
    /// Initializes the game's scene with the scn file provided.
    public init(mainScenePath: String, DBMS: DBManager) {
        self.DBMS = DBMS
        scene = SCNScene(named: mainScenePath)!
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Enables or disables the smog effect.
    public func isSmogOn(_ val: Bool) {
        if val {
            addGrayFilter()
            if smog == nil, let url = Bundle.main.url(forResource: "smog", withExtension: "scn") {
                smog = loadNode(withName: "smog", fromSceneFile: url, worldPosition: SCNVector3(0, 2, 0))
            }
        } else {
            scene.rootNode.filters = [] // remove gray filter
            smog?.removeFromParentNode()
            smog = nil
        }
    }
    
    /**
     Allows the user to place a node specified by the given scn filename and directory.
     - Parameter withName: the name of the node contained within the scn file given.
     - Parameter fromSceneFile: path to the scn file containing the node to load.
     - Parameter nodePlacedCallback: function to call when the user has finished placing the node.
     - Remark: If the node is not found, nothing happens. Also note that only one node at a time can be placed.
     */
    public func letUserPlaceNode(fromShopItem item: ShopItem,
                                 nodePlacedCallback: @escaping () -> Void = {}) {
        guard itemToPlace == nil else { return }
        self.itemToPlace = item
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
        
        guard let items = try? DBMS.getForestItems() else { return }
        
        for item in items {
            if let url = Bundle.main.url(forResource: item.internalName, withExtension: "scn"),
                let node = loadNode(withName: item.internalName,
                     fromSceneFile: url,
                     worldPosition: SCNVector3(item.x, item.y, item.z)) {
                nodeToUUID[node] = item.id
            }
        }
    }
    
    private func loadNode(withName name: String, fromSceneFile url: URL, worldPosition: SCNVector3 = SCNVector3(0,0,0)) -> SCNNode? {
        if let nodeScene = try? SCNScene(url: url),
            let node = nodeScene.rootNode.childNode(withName: name, recursively: false) {
            node.worldPosition = worldPosition
            scene.rootNode.addChildNode(node)
            return node
        }
        return nil
    }
    
    
    @objc
    private func addNewNodeByTouch(_ gesture: UITapGestureRecognizer) {
        if let item = itemToPlace {
            let location = gesture.location(in: self.view)
            
            if let hitResult = scnView.hitTest(location, options: [SCNHitTestOption.ignoreHiddenNodes: true, SCNHitTestOption.firstFoundOnly: true]).first,
                hitResult.node == floor {
                
                // place object with a falling effect by using a y > 0
                let worldPos = SCNVector3(hitResult.worldCoordinates.x, 1.5, hitResult.worldCoordinates.z)
                if let url = Bundle.main.url(forResource: item.internalName, withExtension: "scn"),
                    let node = loadNode(withName: item.internalName, fromSceneFile: url, worldPosition: worldPos) {
                    nodeToUUID[node] = UUID().uuidString
                    if endItemTransaction() {
                        saveToDatabase(node: node)
                    } else {
                        displayErrorAlert()
                    }
                }
                
                // cleanup
                if let recognizer = nodeMoveGestureRecognizer {
                    scnView.removeGestureRecognizer(recognizer)
                }
                itemToPlace = nil
                nodePlacedCallback()
            }
        }
    }
    
    /// Subtracts the points required for the item.
    private func endItemTransaction() -> Bool {
        if let item = itemToPlace,
            let currentScore = try? DBMS.retrieveLatestScore(),
            currentScore >= item.cost {
            do { // ensure score updating did not fail
                try DBMS.updateScore(toValue: currentScore - item.cost)
                return true
            } catch { }
        }
        return false
    }
    
    private func saveToDatabase(node: SCNNode) {
        try? DBMS.saveForestItem(ForestItem(id: nodeToUUID[node] ?? UUID().uuidString,
                                            x: node.worldPosition.x, y: node.worldPosition.y, z: node.worldPosition.z,
                                            internalName: node.name ?? ""))
    }
    
    private func displayErrorAlert() {
        let errorAlert = UIAlertController(title: "Error",
                                      message: "Ops, something went wrong!",
                                      preferredStyle: .alert)
        
        self.present(errorAlert, animated: true)
    }
    
    @objc
    private func moveNodeByTouch(panGesture: UIPanGestureRecognizer) {
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
        print("selected node with name " + (movingNode?.name ?? "nil"))
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
        if let node = movingNode {
            node.physicsBody?.isAffectedByGravity = true
            node.physicsBody?.applyForce(SCNVector3(0, -1, 0), asImpulse: true)
            saveToDatabase(node: node)
        }

        (projectedInitialZ, movingNode) = (nil, nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
