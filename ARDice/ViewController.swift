//
//  ViewController.swift
//  ARDice
//
//  Created by Adrian Bao on 7/17/18.
//  Copyright © 2018 Adrian Bao. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        

        // Create 3D object
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//
//        let sphere = SCNSphere(radius: 0.2)
//
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
//        sphere.materials = [material]
//
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        node.geometry = sphere
//
//        // Place node in sceneView
//        sceneView.scene.rootNode.addChildNode(node)
        
        
        
        
        
        // Add light to introduce shadowing effect/ depth to object
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

        // Create dice node - searching recursively
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {

            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)

            sceneView.scene.rootNode.addChildNode(diceNode)

        } else {

            // error

        }
        
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
    
}
