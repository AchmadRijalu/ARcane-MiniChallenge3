//
//  HitboxEntity.swift
//  ARcane-MiniChallenge3
//
//  Created by Timothy on 15/08/23.
//

import RealityKit
import Combine
import SwiftUI
import ARKit

// HasCollision protocol is vital for enabling collision detection within the entity
class HitboxEntity: Entity, HasModel, HasCollision {
	// Array that holds the collision subscriptions for the entities
	var collisionSubs: [Cancellable] = []
	var arView: ARView = ARView()
	var health: Int = 100
    @ObservedObject var healthviewModel : HealthViewModel
	var textEntity = ModelEntity(mesh: .generateText("", font: UIFont.systemFont(ofSize: 0.01)), materials: [SimpleMaterial(color: .red, isMetallic: false)])
		
    required init(color: UIColor, arView: ARView, healthViewModel: HealthViewModel) {
        self.healthviewModel = healthViewModel
		super.init()
		self.arView = arView
		self.components[CollisionComponent.self] = CollisionComponent(
			shapes: [.generateBox(width: 0.5, height: 1, depth: 0.5)],
			mode: .trigger,
			filter: .sensor
		)
		
		self.components[ModelComponent.self] = ModelComponent(
			mesh: .generateBox(width: 0.5, height: 1, depth: 0.5),
			materials: [
				SimpleMaterial(
					color: color,
					isMetallic: true
				)
			]
		)
		
		self.scale = [0.2, 0.2, 0.2]
		self.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
			massProperties: .default,
			material: .default,
			mode: .static
		)
		
		textEntity = ModelEntity(mesh: .generateText("\(healthviewModel.playerTwoHealth)", extrusionDepth: 0.01, font: UIFont.systemFont(ofSize: 0.1), alignment: .center), materials: [SimpleMaterial(color: .white, isMetallic: false)])
		textEntity.position.z += 0.5
		
		self.addChild(textEntity)
	}
	required init() {
		fatalError("init() has not been implemented")
	}
}

extension HitboxEntity {
  func addCollisions() {
	guard let scene = self.scene else {
	  return
	}

	collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
//		guard let boxA = event.entityA as? HitboxEntity else {
//			return
//		}

//		self.arView.scene.anchors.remove(self)
		
		
		self.removeChild(self.textEntity)
		self.healthviewModel.playerTwoHealth -= 1
		self.textEntity = ModelEntity(mesh: .generateText("\(self.healthviewModel.playerTwoHealth)", extrusionDepth: 0.01, font: UIFont.systemFont(ofSize: 0.1), alignment: .center), materials: [SimpleMaterial(color: .white, isMetallic: false)])
		self.textEntity.position.z += 0.7
		self.addChild(self.textEntity)
	})
	  
	collisionSubs.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
//		guard let boxA = event.entityA as? HitboxEntity else {
//			return
//		}
		
//		boxA.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
	})
  }
}

