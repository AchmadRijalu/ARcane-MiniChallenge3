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
class HitboxEntity: Entity, HasModel, HasCollision, HasAnchoring {
	// Array that holds the collision subscriptions for the entities
	var collisionSubs: [Cancellable] = []
		
	required init(color: UIColor) {
		super.init()
		
		self.components[CollisionComponent.self] = CollisionComponent(
			shapes: [.generateBox(width: 0.5, height: 0.5, depth: 2.5)],
			mode: .trigger,
			filter: .sensor
		)
		
		self.components[ModelComponent.self] = ModelComponent(
			mesh: .generateBox(width: 0.5, height: 0.5, depth: 2.5),
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
		guard let boxA = event.entityA as? HitboxEntity else {
			return
		}

		boxA.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false)]
	})
	  
	collisionSubs.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
		guard let boxA = event.entityA as? HitboxEntity else {
			return
		}
		
		boxA.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
	})
  }
}

