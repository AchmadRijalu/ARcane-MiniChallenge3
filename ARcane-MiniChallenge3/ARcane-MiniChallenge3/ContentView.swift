//
//  ContentView.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 28/07/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    
    var body: some View {
        
        ZStack(alignment: .bottomTrailing){
            ARViewContainer().edgesIgnoringSafeArea(.all)
            
            SpellshootButton().onTapGesture {
                print("tapped")
            }
        }
        
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Experience.Projectile()
//
//        // Add the box anchor to the scene
//        arView.scene.anchors.append(boxAnchor)
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView().previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif
