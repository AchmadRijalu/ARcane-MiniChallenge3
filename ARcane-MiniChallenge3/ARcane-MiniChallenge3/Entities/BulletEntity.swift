//
//  BulletEntity.swift
//  ARcane-MiniChallenge3
//
//  Created by Timothy on 14/08/23.
//

import RealityKit
import Combine
import SwiftUI
import ARKit

// HasCollision protocol is vital for enabling collision detection within the entity
class BulletEntity: Entity, HasModel, HasCollision {
	// Array that holds the collision subscriptions for the entities
	var collisionSubs: [Cancellable] = []
	var arView: ARView = ARView()
	var anchorEntity: AnchorEntity = AnchorEntity()
		
	required init(color: UIColor, for anchor: ARAnchor, arView: ARView, anchorEntity: AnchorEntity) {
		super.init()
		
		self.anchorEntity = anchorEntity
		self.arView = arView
		
		self.components[CollisionComponent.self] = CollisionComponent(
			shapes: [.generateBox(width: 0.5, height: 0.5, depth: 2.5)],
			mode: .trigger,
			filter: .sensor
		)
		
		self.components[ModelComponent.self] = ModelComponent(
			mesh: .generateBox(width: 0.5, height: 0.5, depth: 2.5, cornerRadius: 0.5),
			materials: [SimpleMaterial(
				color: color,
				isMetallic: true)
			]
		)
		
		self.scale = [0.1, 0.1, 0.1]
		self.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
			massProperties: .default,
			material: .default,
			mode: .dynamic
		)
		
		self.components[PhysicsMotionComponent.self] = PhysicsMotionComponent(
			linearVelocity: SIMD3(
				anchor.transform.columns.2.x * -20,
				anchor.transform.columns.2.y * -20,
				anchor.transform.columns.2.z * -20
			)
		)
	}
	
	required init() {
		fatalError("init() has not been implemented")
	}
}

extension BulletEntity {
  func addCollisions() {
	guard let scene = self.scene else {
	  return
	}

	collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
		guard let boxA = event.entityA as? BulletEntity else {
			return
		}

//		self.arView.scene.removeAnchor(self.anchorEntity)
	})
	  
	collisionSubs.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
		guard let boxA = event.entityA as? BulletEntity else {
			return
		}
		
//		boxA.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
	})
  }
}
