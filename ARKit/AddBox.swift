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
    
    var boxNode:SCNNode = {
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        
        return boxNode
        
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let location = touch.location(in: sceneView)
            let hitList = sceneView.hitTest(location, types: [ARHitTestResult.ResultType.featurePoint])
            
            if let result = hitList.first {
                
                let hitTransform = SCNMatrix4(result.worldTransform)
                let hitPosition = SCNVector3Make(hitTransform.m41,hitTransform.m42,hitTransform.m43)
                
                let boxx = boxNode
                boxx.position = hitPosition
                
                sceneView.scene.rootNode.addChildNode(boxx)
            }
        }
    }
    

}//

