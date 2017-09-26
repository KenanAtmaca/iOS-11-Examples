//
//
//  Copyright © 2017 Kenan Atmaca. All rights reserved.
//  kenanatmaca.com
//
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var bigboxNode:SCNNode!

    var boxControl = false
    
    let collisionBox: Int = 1 << 0
    let collsionBigBox: Int = 1 << 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.automaticallyUpdatesLighting = true
        
        // self.sceneView.scene.physicsWorld.gravity = SCNVector3(x:0,y:0.1,z:0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let location = touch.location(in: sceneView)
            let hitList = sceneView.hitTest(location, types: [ARHitTestResult.ResultType.featurePoint])
            
            if let result = hitList.first {
                
                let hitTransform = SCNMatrix4(result.worldTransform)
                let hitPosition = SCNVector3Make(hitTransform.m41,hitTransform.m42,hitTransform.m43)
                
                let bigbox = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
                bigboxNode = SCNNode(geometry: bigbox)
                bigboxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                bigboxNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                bigboxNode.physicsBody?.categoryBitMask = self.collsionBigBox
                bigboxNode.physicsBody?.collisionBitMask = self.collisionBox
                bigboxNode.position = hitPosition
                sceneView.scene.rootNode.addChildNode(bigboxNode)
                
            }
        }
    }
    
    @IBAction func basAct(_ sender: Any) {
     
        let bbPos = bigboxNode.position
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(x:bbPos.x,y:bbPos.y + 0.5,z:bbPos.z)
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        boxNode.physicsBody?.categoryBitMask = self.collisionBox
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
        
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}//

