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
import MultipeerConnectivity

// HasCollision protocol is vital for enabling collision detection within the entity
class HitboxEntity: Entity, HasModel, HasCollision {
	// Array that holds the collision subscriptions for the entities
	var collisionSubs: [Cancellable] = []
	var textEntity = ModelEntity(mesh: .generateText("", font: UIFont.systemFont(ofSize: 0.01)), materials: [SimpleMaterial(color: .red, isMetallic: false)])
	@ObservedObject var playerModel: PlayerModel
		
	required init(color: UIColor, playerModel: PlayerModel) {
        self.playerModel = playerModel
		super.init()
		
		self.components[CollisionComponent.self] = CollisionComponent(
			shapes: [.generateBox(width: 0.2, height: 0.2, depth: 0.1)],
			mode: .trigger,
			filter: .sensor
		)
		
		self.components[ModelComponent.self] = ModelComponent(
			mesh: .generateBox(width: 0.2, height: 0.2, depth: 0.1),
			materials: [
				SimpleMaterial(
					color: color,
					isMetallic: true
				)
			]
		)
		
		self.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
			massProperties: .default,
			material: .default,
			mode: .static
		)
		
		self.position.y += 0.22
		
		textEntity = ModelEntity(mesh: .generateText("\(playerModel.health)", extrusionDepth: 0.01, font: UIFont.systemFont(ofSize: 0.2), alignment: .center), materials: [SimpleMaterial(color: .white, isMetallic: false)])
		textEntity.position.z += -0.1
		textEntity.position.y += 0.07
		
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
		self.playerModel.health -= 1
		self.textEntity = ModelEntity(mesh: .generateText("\(self.playerModel.health)", extrusionDepth: 0.01, font: UIFont.systemFont(ofSize: 0.2), alignment: .center), materials: [SimpleMaterial(color: .white, isMetallic: false)])
		self.textEntity.position.z += -0.1
		self.textEntity.position.y += 0.07
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

