//
//
//  Copyright © 2017 Kenan Atmaca. All rights reserved.
//  kenanatmaca.com
//
//

import UIKit
import SceneKit
import ARKit

enum butState: String {
    case start = "Tap start AR"
    case stop = "Stop tracking"
    case select = "Tap plane select"
    case reset = "Reset"
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    var arState = butState.start
    var scene = SCNScene()
    var configuration = ARWorldTrackingConfiguration()
    
    var anchors = [ARAnchor]()
    var nodes = [SCNNode]()
    var planeNodesCount = 0
    var planeHeight: CGFloat = 0.01
    var disableTracking = false
    var isPlaneSelected = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        
        self.sceneView.scene = scene
        self.sceneView.autoenablesDefaultLighting = true
        
        self.sceneView.debugOptions  = [.showConstraints, .showLightExtents]
        self.sceneView.showsStatistics = false
        self.sceneView.automaticallyUpdatesLighting = true
        menuButton.setTitle(arState.rawValue , for: .normal)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSessionConfiguration(pd: .horizontal, runOPtions: .resetTracking)
        
    }
    
    func setSessionConfiguration(pd : ARWorldTrackingConfiguration.PlaneDetection,
                                 runOPtions: ARSession.RunOptions) {
  
        configuration.planeDetection = pd
        sceneView.session.run(configuration, options: runOPtions)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // DELEGATE
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard disableTracking == false else {
            return nil
        }
        var node:  SCNNode?
        if let planeAnchor = anchor as? ARPlaneAnchor {
            
            node = SCNNode()
            let planeGeometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: planeHeight, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0.0)
            planeGeometry.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "tron")
            planeGeometry.firstMaterial?.specular.contents = UIColor.white
            let planeNode = SCNNode(geometry: planeGeometry)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
               //   planeNode.transform = SCNMatrix4MakeRotation(Float(-CGFloat.pi/2), 1, 0, 0) vertical node
            node?.addChildNode(planeNode)
            anchors.append(planeAnchor)
            
        } else {
            
            print("not plane anchor \(anchor)")
        }
        return node
    }
    
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        planeNodesCount += 1
        if node.childNodes.count > 0 && planeNodesCount % 2 == 0 {
            node.childNodes[0].geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard disableTracking == false else {
            return
        }
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            if anchors.contains(planeAnchor) {
                if node.childNodes.count > 0 {
                    let planeNode = node.childNodes.first!
                    planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight / 2), planeAnchor.center.z)
                    if let plane = planeNode.geometry as? SCNBox {
                        plane.width = CGFloat(planeAnchor.extent.x)
                        plane.length = CGFloat(planeAnchor.extent.z)
                        plane.height = planeHeight
                    }
                }
            }
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("remove node delegate called")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        
        if arState == .select {
            selectExistinPlane(location: location)
        }
        
    }
    
    func selectExistinPlane(location: CGPoint) {
        let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        if hitResults.count > 0 {
            let result: ARHitTestResult = hitResults.first!
            if let planeAnchor = result.anchor as? ARPlaneAnchor {
                for var index in 0...anchors.count - 1 {
                    if anchors[index].identifier != planeAnchor.identifier {
                        sceneView.node(for: anchors[index])?.removeFromParentNode()
                    }
                    index += 1
                }
                anchors = [planeAnchor]
                setTexture(node: sceneView.node(for: anchors[0])!)
            }
        }
    }
    
    func reset() {
        
        if anchors.count > 0 {
            for index in 0...anchors.count - 1 {
                sceneView.node(for: anchors[index])?.removeFromParentNode()
            }
            anchors.removeAll()
        }
        
        for node in sceneView.scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
        
    }
    
    func setTexture(node: SCNNode) {
        if let geometryNode = node.childNodes.first {
            if node.childNodes.count > 0 {
                geometryNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "texttt")
                geometryNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
                geometryNode.geometry?.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
                geometryNode.geometry?.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
                geometryNode.geometry?.firstMaterial?.diffuse.mipFilter = SCNFilterMode.linear
            }
            arState = butState.reset
            menuButton.setTitle(butState.reset.rawValue, for: .normal)
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            statusLabel.text = "Normal"
        case .notAvailable:
            statusLabel.text = "Not Available"
        case .limited(let reason):
            statusLabel.text = "Limited with reason: "
            switch reason {
            case .excessiveMotion:
                statusLabel.text = statusLabel.text! + "excessive camera movement"
            case .insufficientFeatures:
                statusLabel.text = statusLabel.text! + "insufficient features"
            case .initializing:
                statusLabel.text = statusLabel.text! + "init features"
            }
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        switch arState {
        case .start:
            disableTracking = false
            setSessionConfiguration(pd: ARWorldTrackingConfiguration.PlaneDetection.horizontal, runOPtions: ARSession.RunOptions.resetTracking)
            arState = .stop
            menuButton.setTitle(butState.stop.rawValue, for: .normal)
            
        case .stop:
            disableTracking = true
            arState = butState.select
            menuButton.setTitle(butState.select.rawValue, for: .normal)
            
        case .select:
            arState = butState.reset
            menuButton.setTitle(butState.reset.rawValue, for: .normal)
            break
        case .reset:
            disableTracking = false
            arState = .start
            menuButton.setTitle(butState.start.rawValue, for: .normal)
            reset()
            configuration = ARWorldTrackingConfiguration()
            break
        }
    }
   
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}//
