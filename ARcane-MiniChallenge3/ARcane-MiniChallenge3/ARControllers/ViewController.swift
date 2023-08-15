//
//  ViewController.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 01/08/23.
//

import Foundation
import ARKit
import RealityKit
import AVFoundation
import SwiftUI
import MultipeerSession
import UIKit
import FocusEntity


class ViewController: UIViewController {
    
    var arView: ARView = {
        let arView = ARView(frame: .zero)
        
        // give physics to ar view environment
        arView.environment.sceneUnderstanding.options.insert([.collision, .physics, .occlusion])
        
        return arView
    }()
    
    //setup the mutlipeer package
    var shootAudioPlayer : AVAudioPlayer!
    var multipeerSession: MultipeerSession?
    var sessionIDObservation: NSKeyValueObservation?
    var connectedPeers: [UUID: String] = [:]
    
    //setup the arcoachignoverlay
    let coachingOverlay = ARCoachingOverlayView()
    var message:MessageLabel = MessageLabel()
    //    var emptyMessage:UILabel = UILabel
    //Did Appear
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = .clear
        self.view.addSubview(self.arView)
        self.view.addSubview(self.message)
        
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: self.view.topAnchor),
            arView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            arView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            arView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        self.view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        arView.session.delegate = self
        
        setupARView()
        
        //        setupMultipeerSession()
        setupCoachingOverlay()
        message.displayMessage("Track your phone to find some players", duration: 60.0)
        
        message.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Center the label horizontally
            message.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Position the label at the top with a margin of 20 points
            message.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            
            // Add other constraints as needed
        ])
        
        message.layer.cornerRadius = 10
        message.ignoreMessages = false
        message.textAlignment = .center
        //		let hitbox = HitboxEntity(color: .systemPink)
        //
        //		arView.scene.anchors.append(hitbox)
        //		hitbox.addCollisions()
    }
    
    //setup the AR View
    func setupARView(){
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
        //        arView.debugOptions = [.showSceneUnderstanding, .showPhysics]
#endif
        
        configuration.isCollaborationEnabled = true
        arView.session.run(configuration)
    }
    
    func setupMultipeerSession(){
        //Use the key-value observation to monitor the ARSession
        sessionIDObservation =
        arView.session.observe(\.identifier, options: [.new]){
            object, change in
            print("SessionID changed to : \(change.newValue)")
            guard let multipeerSession = self.multipeerSession else{return}
            
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
        multipeerSession = MultipeerSession(serviceName: "multiuser-ar", receivedDataHandler: self.receivedData, peerJoinedHandler: self.peerJoined, peerLeftHandler: self.peerLeft, peerDiscoveredHandler: self.peerDiscovered)
    }
    
    
    func spellShoot(){
        let anchor = ARAnchor(name: "SpellShoot", transform: arView.cameraTransform.matrix)
        arView.session.add(anchor: anchor)
        
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor){
        // Mesh
        //		let spellEntity = ModelEntity(mesh: .generateBox(width: 0.5, height: 0.5, depth: 2.5, cornerRadius: 0.5), materials: [SimpleMaterial(color: .systemPink, isMetallic: true)])
        //		spellEntity.scale = [0.1, 0.1, 0.1]
        //
        //		spellEntity.collision = CollisionComponent(shapes: [.generateBox(width: 0.5, height: 0.5, depth: 2.5)])
        //		spellEntity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        //		spellEntity.physicsMotion = PhysicsMotionComponent(linearVelocity: SIMD3(anchor.transform.columns.2.x * -20, anchor.transform.columns.2.y * -20, anchor.transform.columns.2.z * -20))
        
        let spellEntity = BulletEntity(color: .systemPink, for: anchor)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(spellEntity)
        arView.scene.addAnchor(anchorEntity)
        
        spellEntity.addCollisions()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.70){
            self.arView.scene.removeAnchor(anchorEntity)
        }
    }
    
    
    
}

extension ViewController: ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "SpellShoot" {
                placeObject(named: anchorName, for : anchor)
                
            }
            
            if let playerAnchor = anchor as? ARParticipantAnchor {
                print("Success connected with : \(playerAnchor.sessionIdentifier)")
                let anchorEntity = AnchorEntity(anchor: playerAnchor)
                let mesh = MeshResource.generateSphere(radius: 0.03)
                
                let color = UIColor.green
                
                let material = SimpleMaterial(color: color, isMetallic: false)
                
                let coloredSphered = ModelEntity(mesh: mesh, materials: [material])
                
                anchorEntity.addChild(coloredSphered)
                
                arView.scene.addAnchor(anchorEntity)
            }
        }
        
        
    }
}




//MARK: - This is Multipeer Extension start
extension ViewController{
    private func sendARSessionIDTo(peers:[PeerID]){
        guard let multipeerSession = multipeerSession else {
            return
        }
        let idString = arView.session.identifier.uuidString
        let command = "SessionID" + idString
        if let commandData = command.data(using: .utf8){
            multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
        }
    }
    
    func receivedData(_ data : Data, from peer: PeerID){
        guard let multipeerSession = multipeerSession else {return}
        
        //Displaing all the players doing
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data){
            arView.session.update(with: collaborationData)
        }
        
        let sessionIDCommandString = "SessionID"
        
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString){
            let newSessionID = String(commandString[commandString.index( commandString.startIndex, offsetBy: sessionIDCommandString.count)...])
            
            if let oldSessionID = multipeerSession.peerSessionIDs[peer]{
                removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
            }
            
            multipeerSession.peerSessionIDs[peer] = newSessionID
        }
    }
    
    func peerDiscovered(_ peer: PeerID) -> Bool {
        guard let multipeerSession = multipeerSession else {return false}
        
        if multipeerSession.connectedPeers.count > 2{
            print("There's some player wants to join but the limitation of peers, it can't join the battle")
            return false
        }
        else{
            return true
        }
        
    }
    func peerJoined(_ peer: PeerID){
        print("A Player wants to join hold it")
        message.displayMessage("""
                   \(peer.displayName) is joining
            """, duration: 6.0)
        //provide it the session ID to the new user so they can your track the anchors
//        if let playerAnchor = arView.session.currentFrame?.anchors.first {
//            let indicatorEntity = createPlayerIndicator(playerName: connectedPeers[peer] ?? "Unknown")
//            playerAnchor.addChild(indicatorEntity)
//        }
    }
    
    func peerLeft(_ peer:PeerID){
        guard let multipeerSession = multipeerSession else { return}
        
        print("The player \(peer.displayName) is leaving the game")
        
        if let sessionID = multipeerSession.peerSessionIDs[peer]{
            removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
            multipeerSession.peerSessionIDs.removeValue(forKey: peer)
        }
        
    }
    
    private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier:String){
        guard let frame = arView.session.currentFrame else {return}
        
        for anchor in frame.anchors{
            guard let anchorSessionID = anchor.sessionIdentifier else {continue}
            if anchorSessionID.uuidString == identifier{
                arView.session.remove(anchor: anchor)
            }
        }
    }
    
    func session(_ session:ARSession, didOutputCollaborationData data : ARSession.CollaborationData){
        guard let multipeerSession = multipeerSession else {return}
        if !multipeerSession.connectedPeers.isEmpty{
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
            else {
                fatalError("unexpected failed to encode collaboration data ")
            }
            
            let dataIsCritical = data.priority == .critical
            multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
            
        }
        else{
            //            print("Deferred sending collaboration to later because there are no peers")
            message.displayMessage("Finding Local Players")
        }
    }
}

extension float4x4 {
    var forward: SIMD3<Float> {
        normalize(SIMD3<Float>(-columns.2.x, -columns.2.y, -columns.2.z))
    }
}
