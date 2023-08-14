//
//  ViewStartController.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 11/08/23.
//

import Foundation
import SwiftUI
import RealityKit


struct ARViewStartController : UIViewRepresentable{
    
   
    func makeUIView(context: Context) -> ARView {
            return ARView(frame: .zero)
        }
        
        func updateUIView(_ uiView: ARView, context: Context) {
            updateCounter(uiView: uiView)
        }
        
        private func updateCounter(uiView: ARView) {
            uiView.scene.anchors.removeAll()
            let anchor = AnchorEntity()
           
            uiView.scene.addAnchor(anchor)
        }
}
