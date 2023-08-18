//
//  ViewStartController.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 11/08/23.
//

import Foundation
import SwiftUI
import RealityKit


struct ARViewCounterController : UIViewRepresentable{
    
    @ObservedObject var countDown : StartViewModel
    func makeUIView(context: Context) -> ARView {
            return ARView(frame: .zero)
        }
        
        func updateUIView(_ uiView: ARView, context: Context) {
            updateCounter(uiView: uiView)
        }
        
        private func updateCounter(uiView: ARView) {
            uiView.scene.anchors.removeAll()
            let anchor = AnchorEntity()
            let text = MeshResource.generateText("\(abs(countDown.countDown))", extrusionDepth: 0.06, font: .systemFont(ofSize: 0.5, weight: .bold))

            let color: UIColor
            if countDown.countDown < 3 {
                color = .red
            }
            else{
                color = .green
            }
            let shader = SimpleMaterial(color: color, roughness: 6, isMetallic: true)
            let textEntity = ModelEntity(mesh: text, materials: [shader])
            textEntity.position.z -= 1.5
            textEntity.setParent(anchor)
            uiView.scene.addAnchor(anchor)
        }
}
