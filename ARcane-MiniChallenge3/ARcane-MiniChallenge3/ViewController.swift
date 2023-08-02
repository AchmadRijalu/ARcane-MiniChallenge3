//
//  ViewController.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 01/08/23.
//

import Foundation
import ARKit
import RealityKit
import AVFoundation
import SwiftUI

class ViewController: UIViewController {
    var arView: ARView = {
        let arView = ARView(frame: .zero)
        return arView
    }()
    
    var shootAudioPlayer : AVAudioPlayer!
    //Did Appear
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
                
        self.view.addSubview(self.arView)
                    
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: self.view.topAnchor),
            arView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            arView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            arView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        self.view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        arView.session.delegate = self
        setupARView()
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
//        arView.addGestureRecognizer(tapGestureRecognizer)
    }
    //setup the AR View
    func setupARView(){
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
    }
//     @objc public func handleTap(recognizer: UITapGestureRecognizer){
//         print("shot")
//        let anchor = ARAnchor(name: "ProjectileObject", transform: arView.cameraTransform.matrix)
//        arView.session.add(anchor: anchor)
//    }
    
    func testHit(){
        let anchor = ARAnchor(name: "ProjectileObject", transform: arView.cameraTransform.matrix)
        arView.session.add(anchor: anchor)
    }
    
    func placeObject(named entityName: String, for anchor:ARAnchor){
        let spellEntity = try! ModelEntity.load(named: entityName)
        //This is for position or reallocate anchor in the same orientation
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(spellEntity)
        arView.scene.addAnchor(anchorEntity)
    }
}
extension ViewController: ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "ProjectileObject"{
                placeObject(named: anchorName, for : anchor)
            }
        }
    }
}
