//
//  ARViewContainer.swift
//  ARcane-MiniChallenge3
//
//  Created by Timothy on 04/08/23.
//

import Foundation
import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
	
	func makeUIView(context: Context) -> ARView {
		
		let arView = ARView(frame: .zero)
		
		// give physics to ar view environment
		arView.environment.sceneUnderstanding.options.insert([.collision, .physics, .occlusion])
		
		// Starting AR session with LIDAR configuration
		let configuration = ARWorldTrackingConfiguration()
		
		configuration.environmentTexturing = .automatic
		configuration.sceneReconstruction = .mesh
		
		if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
			// read surroundings and create a depth map using the sensor
			configuration.frameSemantics = .sceneDepth
		}
		
		arView.automaticallyConfigureSession = false
		
		#if DEBUG
		arView.debugOptions = [.showSceneUnderstanding]
		#endif
		
		return arView
	}
	
	func updateUIView(_ uiView: ARView, context: Context) {}
	
}
