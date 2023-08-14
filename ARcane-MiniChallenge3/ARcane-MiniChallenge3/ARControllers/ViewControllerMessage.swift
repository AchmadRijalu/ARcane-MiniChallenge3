//
//  ViewControllerMessage.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 10/08/23.
//

import Foundation
import ARKit

extension ViewController: ARCoachingOverlayViewDelegate{
    
    
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        message.ignoreMessages = true
        message.isHidden = true
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        message.ignoreMessages = false

    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        guard let configuration = arView.session.configuration else { print("A configuration is required"); return }
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    func setupCoachingOverlay(){
        // Set up coaching view
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
        coachingOverlay.goal = .geoTracking
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
    }
}
