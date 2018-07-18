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

    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Used for testing detection of plane
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
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
        
        
        
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Allows plane detection for dice
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // Detecting touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Use ARKit to convert touch to convert to real world location
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            // Convert 2D touchLocation to a 3D touchLocation for AR environment
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                // print(hitResult) // Prints coordinates
                
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                // Create dice node - searching recursively
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,  // Adjusted to sit above plane rather than in the middle of plane
                        z: hitResult.worldTransform.columns.3.z
                    )
                    
                    diceArray.append(diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                    
                } else {
                    
                    // error
                    
                }
            }
            
        } else {
            // No touch was detected
        }
    }
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
        
    }
    
    
    func roll(dice: SCNNode) {
        // Randomization for rotations of dice used in animation
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        
        // Animate
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    
    // Rolls dice when pressed
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    // Roll with shake gesture
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    
    
    // Triggered when plane is detected - as anchor
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            
            // Downcast
            let planeAnchor = anchor as! ARPlaneAnchor
            
            // Convert to Scene Plane
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            // Create plane node
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            // Rotate plane to become horizontal rather than vertical
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            // This achievs the same as sceneView.scene.rootNode.addChildNode(planeNode)
            node.addChildNode(planeNode)
            
        } else {
            // exit
            return
        }
    }
    
    
    
    
    
    
    
    
}
