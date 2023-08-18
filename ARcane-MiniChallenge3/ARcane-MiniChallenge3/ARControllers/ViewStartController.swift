//
//  ViewStartController.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 11/08/23.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit
import FocusEntity



struct ARViewStartController : UIViewRepresentable{
    func makeUIView(context: Context) -> ARView {
        
        let view = ARView()
        
        //Start AR Session
        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        
        view.addSubview(coachingOverlay)
        
        // Set debug options
        //#if DEBUG
        //        view.debugOptions = [.showPhysics, .showAnchorGeometry]
        //#endif
        
        //MARK: - Adding the object by tapping the screen
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(recognizer:)))
        )
        
        
        context.coordinator.view = view
        session.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        StartFunction(uiView: uiView)
    }
    
    private func StartFunction(uiView: ARView) {
        uiView.scene.anchors.removeAll()
        let anchor = AnchorEntity()
        
        uiView.scene.addAnchor(anchor)
    }
    
    
    //MARK: - Detecting the coordincate
    func makeCoordinator() -> Coordinator{
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var arObject :ARObjectModel = ARObjectModel()
        var objectPlaced = false
        weak var view: ARView?
        var focusEntity: FocusEntity?
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let view = self.view else { return }
            debugPrint("Anchors added to the scene: ", anchors)
            focusEntity?.removeFromParent()
            self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
            
           
        }
        
        
        @objc func handleTap(recognizer: UITapGestureRecognizer){
            guard let view = self.view, let focusEntity = self.focusEntity , !objectPlaced else {return}
            
            let tapLocation = recognizer.location(in: view)
            // Perform hit testing to find ARPlaneAnchor at the tapped location
            let hitTestResults = view.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            if let hitTestResult = hitTestResults.first{
                //Create a new anchor to add content to
                let anchor = AnchorEntity()
                view.scene.anchors.append(anchor)
                //add the start object from reality file
                let startObject = try! ModelEntity.load(named: "MenuExperience")
                startObject.position = focusEntity.position + SIMD3(0, 1, 0)
                startObject.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateBox(width: 1.08, height: 65.5, depth: 0.5)])
                anchor.addChild(startObject)
                
                
                if !objectPlaced {
                    objectPlaced = true
                    arObject.isObjectPlaced = true
                    arObject.objectPosition = startObject.position
                    
                    print(objectPlaced)
                    print(arObject.isObjectPlaced)
                   
                }
                
                
            }
            
            
            
            //            let box = MeshResource.generateBox(size: 0.5, cornerRadius: 0.05)
            //            let material = SimpleMaterial(color: .red, isMetallic: true)
            //            let diceEntity = ModelEntity(mesh: box, materials: [material])
            //            diceEntity.position = focusEntity.position
            //
            
        }
    }
    
}
