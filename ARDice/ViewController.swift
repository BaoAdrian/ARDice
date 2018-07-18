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
        // self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
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
    
    
    
    //MARK: - Dice Rendering Methods
    
    
    
    
    // Detecting touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Use ARKit to convert touch to convert to real world location
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            // Convert 2D touchLocation to a 3D touchLocation for AR environment
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                // print(hitResult) // Prints coordinates
                
                addDice(atLocation: hitResult)
                
            }
            
        } else {
            // No touch was detected
        }
    }
    
    
    func addDice(atLocation location: ARHitTestResult) {
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        // Create dice node - searching recursively
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,  // Adjusted to sit above plane rather than in the middle of plane
                z: location.worldTransform.columns.3.z
            )
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
            
        } else {
            
            // error
            
        }
    }
    
    
    
    
    
    //MARK: - Dice Rolling Methods
    
    
    
    
    
    func roll(dice: SCNNode) {
        // Randomization for rotations of dice used in animation
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        
        // Animate
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
        
    }
    
    // Rolls dice when pressed
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    // Roll with shake gesture
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
        
    }
    
    
    //MARK: - ARSceneView Delegate Methods
    
    
    // Triggered when plane is detected - as anchor
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Refactored code replacing the commented code below
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        // This achievs the same as sceneView.scene.rootNode.addChildNode(planeNode)
        node.addChildNode(planeNode)

    }
    
    
    
    //MARK: - Plane Rendering Methods
    
    
    
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
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
        
        return planeNode
    }
    
}
