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
import UIKit
import FocusEntity
import MultipeerConnectivity

class ViewController: UIViewController {
	var devicePeerID: MCPeerID
    var healthviewModel : HealthViewModel?
    var healthLabel =  UILabel()
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
    //    var connectedPeers: [UUID: String] = [:]
    var connectedPeers: [UUID] = []
    
    //setup the arcoachignoverlay
    let coachingOverlay = ARCoachingOverlayView()
    var message:MessageLabel = MessageLabel()
    
    
    //setup the countdown AR Object
    var countdownLabel: UILabel!
    var countdownTimer: Timer?
    var countdownCounter = 5
    var countdownIsOn:Bool = false
    
    
    var playerHealthMapping: [UUID: Int] = [:]
    
    
    //Did Appear
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = .clear
        self.view.addSubview(self.arView)
        self.view.addSubview(self.message)
        
        //        healthLabel.translatesAutoresizingMaskIntoConstraints = false
        //        healthLabel.textAlignment = .left
        //        healthLabel.font = UIFont.systemFont(ofSize: 18)
        //        healthLabel.text = "Finger X Position"
        //        healthLabel.numberOfLines = 0
        //        view.addSubview(healthLabel)
        //
        //        NSLayoutConstraint.activate([
        //            healthLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        //            healthLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
        //
        //        ])
        
        
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
        setupCoachingOverlay()
        setupMultipeerSession()
        //        message.displayMessage("Track your phone to find some players", duration: 60.0)
        message.translatesAutoresizingMaskIntoConstraints = false
        UIApplication.shared.isIdleTimerDisabled = true
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
		
//		let hitbox = HitboxEntity(color: .systemPink, arView: arView)
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
		multipeerSession.my
    }
    
    func spellShoot() {
        let anchor = ARAnchor(name: "SpellShoot", transform: arView.cameraTransform.matrix)
        arView.session.add(anchor: anchor)
    }
	
    func blockDeploy() {
        let anchor = ARAnchor(name: "BlockDeploy", transform: arView.cameraTransform.matrix)
        arView.session.add(anchor: anchor)
    }
	
    func placeObjectBlock(named entityName: String, for anchor: ARAnchor) {
        // Calculate the position for the square closer to the anchor
        let anchorTransform = anchor.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.2 // Move the square closer to the anchor
        let transformedTransform = simd_mul(anchorTransform, translationMatrix)
        
        // Create the square entity
        let squareSize: Float = 0.2 // Adjust the size as needed
        let squareEntity = ModelEntity(mesh: .generateBox(width: squareSize, height: squareSize, depth: 0.01), materials: [SimpleMaterial(color: UIColor(Color("SecondButtonColor")), isMetallic: true)])
        squareEntity.collision = CollisionComponent(shapes: [.generateBox(width: squareSize, height: squareSize, depth: 0.01)])
        squareEntity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        // Create an anchor entity at the transformed position and add the square entity
        let anchorEntity = AnchorEntity(world: transformedTransform)
        anchorEntity.addChild(squareEntity)
        
        // Add the anchor entity to the AR view's scene
        arView.scene.addAnchor(anchorEntity)
        
        // Remove the anchor entity after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.arView.scene.removeAnchor(anchorEntity)
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor){
        let anchorEntity = AnchorEntity(anchor: anchor)
        
        let spellEntity = BulletEntity(color: .systemPink, for: anchor)
        
        anchorEntity.addChild(spellEntity)
        arView.scene.addAnchor(anchorEntity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.70){
            self.arView.scene.removeAnchor(anchorEntity)
        }
    }
    
    func printConnectedPeers() {
        let connectedPeerNames = multipeerSession!.connectedPeers.map { $0.displayName }
        let connectedPeersText = connectedPeerNames.joined(separator: ", ")
        print("Connected peers: \(connectedPeersText)")
    }
    
    func startCountdown() {
        countdownLabel = UILabel()
        countdownLabel.textColor = .white
        countdownLabel.font = UIFont.systemFont(ofSize: 24)
        countdownLabel.textAlignment = .center
        countdownLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        countdownLabel.center = arView.center
        arView.addSubview(countdownLabel)
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.countdownCounter -= 1
            self.countdownLabel.text = "\(self.countdownCounter)"
            if self.countdownCounter == 0 {
                self.countdownTimer?.invalidate()
                self.countdownLabel.removeFromSuperview()
            }
        }
    }
    
}
extension ViewController: ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "SpellShoot" {
                placeObject(named: anchorName, for : anchor)
            }
			
			if let anchorName = anchor.name, anchorName == "BlockDeploy"{
				placeObjectBlock(named: anchorName, for: anchor)
			}
			
			if let playerAnchor = anchor as? ARParticipantAnchor {
//				print("Success connected with another player")
//				let anchorEntity = AnchorEntity(anchor: playerAnchor)
//
//				let playerEntity = HitboxEntity(color: .green, arView: arView)
//
//				anchorEntity.addChild(playerEntity)
//
//				arView.scene.addAnchor(anchorEntity)
				
				
				let playerEntity = HitboxEntity(color: .green, arView: arView, healthViewModel: healthviewModel ?? HealthViewModel())
				playerEntity.position += SIMD3<Float>(0, 0, -1)
				
				let anchorEntity = AnchorEntity(.camera)
				anchorEntity.addChild(playerEntity)
				
				arView.scene.anchors.append(anchorEntity)
				
				playerEntity.addCollisions()
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
       
        printConnectedPeers()
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
            //                        print("Deferred sending collaboration to later because there are no peers")
            message.displayMessage("Finding Local Players")
            
            
        }
    }
}

extension float4x4 {
    var forward: SIMD3<Float> {
        normalize(SIMD3<Float>(-columns.2.x, -columns.2.y, -columns.2.z))
    }
}
