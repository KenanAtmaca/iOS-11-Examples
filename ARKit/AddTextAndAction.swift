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
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.automaticallyUpdatesLighting = true
        
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
                
                let ball = SCNSphere(radius: 0.1)
                let node = SCNNode(geometry: ball)
                
                let myStar = SCNMaterial()
                
                myStar.diffuse.contents = #imageLiteral(resourceName: "world")
                myStar.shininess = 1
                myStar.transparency = 1
                node.geometry?.materials = [myStar]
                node.position = hitPosition
             //   sceneView.scene.rootNode.addChildNode(node)
                
                let action = SCNAction.rotate(by: 360 * CGFloat.pi / 180.0, around: SCNVector3(x:0,y:1,z:0), duration: 12)
                let repeatAct = SCNAction.repeatForever(action)
                node.runAction(repeatAct)
                
                let text = SCNText(string: "HELLO :)", extrusionDepth: 0.02)
                let font = UIFont(name: "Futura", size: 0.15)
                text.font = font
                text.alignmentMode = kCAAlignmentCenter
                text.firstMaterial?.diffuse.contents = UIColor.red
                text.firstMaterial?.specular.contents = UIColor.white
                text.firstMaterial?.isDoubleSided = true
                text.chamferRadius = 0.01
                
                let (minBound, maxBound) = text.boundingBox
                let textNode = SCNNode(geometry: text)
                textNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, 0.02/2)
                textNode.scale = SCNVector3Make(0.1, 0.1, 0.1)
                textNode.position = hitPosition
                
                sceneView.scene.rootNode.addChildNode(textNode)
            }
        }
    }
    

}//

