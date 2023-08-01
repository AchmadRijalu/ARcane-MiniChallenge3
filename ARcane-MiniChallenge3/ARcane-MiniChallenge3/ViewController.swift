//
//  ViewController.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 28/07/23.
//

import Foundation
import ARKit
import RealityKit

class ViewController: UIViewController{
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func setupARView(){
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
    }
    
}
