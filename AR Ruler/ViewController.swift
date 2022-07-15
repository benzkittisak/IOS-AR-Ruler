//
//  ViewController.swift
//  AR Ruler
//
//  Created by Kittisak Panluea on 14/7/2565 BE.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
//    array ตัวนี้สร้างมาเพื่อติดตามจุดสีแดงทั้งหมดที่เราใส่ลงไปในซีนของเรา
    var dotNodes = [SCNNode]()
    
//    สร้างตัวแปรไว้เก็บข้อความ 3 มิติ
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - 1. Touched Function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        มาทำเงื่อนไขตรวจสอบว่าถ้าจุดแดงๆ มีมากกว่า 2 จุดเราจะให้มันเคลียร์จุดทั้งหมดออกก่อน
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        guard let touchLocation = touches.first?.location(in: sceneView) else { return }
        
        let hitTestResults = sceneView.hitTest(touchLocation , types:.featurePoint)
        
        if let hitResult = hitTestResults.first {
            addDot(at:hitResult)
        }
        
    }
    
    func addDot(at hitResult:ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    // MARK: - 2. Calculate Function
    
    func calculate(){
        /*
         การคำนวณความยาวระหว่างจุดสองจุดเนี่ยแน่นอนว่ามันต้องคำนวณมาจากจุดแรกที่เราจิ้มลงไป และจุดที่สองที่เราจิ้มลง
         เอาระยะห่างระหว่างจุดมาคำนวณเอา
         */
//        จุดสีแดงจุดแรก
        let start = dotNodes[0]
//        จุดสีแดงจุดที่สอง
        let end = dotNodes[1]
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
//        print(abs(distance))
        updateText(text:"\(abs(distance))" , at: end.position)
    }
    
    // MARK: - 3. Update Text Function
    func updateText(text:String , at position:SCNVector3){
        
        textNode.removeFromParentNode()
        
//        extrusionDepth = ความลึกของข้อความในแบบ 3 มิติน่ะนะ
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.01 , z: position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
