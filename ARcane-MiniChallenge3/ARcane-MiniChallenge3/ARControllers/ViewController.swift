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

class ViewController: UIViewController {
    var arView: ARView = {
        let arView = ARView(frame: .zero)
        return arView
    }()
    
    //setup the mutlipeer package
    var shootAudioPlayer : AVAudioPlayer!
    var multipeerSession: MultipeerSession?
    var sessionIDObservation: NSKeyValueObservation?
    
    //Did Appear
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = .clear
        self.view.addSubview(self.arView)
                    
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
        setupMultipeerSession()
    }
    //setup the AR View
    func setupARView(){
		// give physics to ar view environment
		arView.environment.sceneUnderstanding.options.insert([.collision, .physics, .occlusion])
		
		// Starting AR session with LIDAR configuration
		let configuration = ARWorldTrackingConfiguration()
		
		configuration.planeDetection = [.horizontal, .vertical]
		configuration.environmentTexturing = .automatic
		configuration.sceneReconstruction = .mesh
		
		if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
			// read surroundings and create a depth map using the sensor
			configuration.frameSemantics = .sceneDepth
		}
		
		arView.automaticallyConfigureSession = false
		
//		#if DEBUG
//		arView.debugOptions = [.showSceneUnderstanding]
//		#endif
        
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
            
            
            //Automatically looking for other player using multipeer
           

        }
        multipeerSession = MultipeerSession(serviceName: "multiuser-ar", receivedDataHandler: self.receivedData, peerJoinedHandler: self.peerJoined, peerLeftHandler: self.peerLeft, peerDiscoveredHandler: self.peerDiscovered)
    }

    
    func spellShoot(){
        let anchor = ARAnchor(name: "ProjectileObject", transform: arView.cameraTransform.matrix)
        arView.session.add(anchor: anchor)
    }
    
    func placeObject(named entityName: String, for anchor:ARAnchor){
        let spellEntity = try! ModelEntity.load(named: entityName)
        //This is for position or reallocate anchor in the same orientation
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(spellEntity)
        arView.scene.addAnchor(anchorEntity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60){
            self.arView.scene.removeAnchor(anchorEntity)
        }
    }
}
extension ViewController: ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "ProjectileObject"{
                placeObject(named: anchorName, for : anchor)
            }
            
            if let playerAnchor = anchor as? ARParticipantAnchor {
                print("Success connected with another player")
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
        
        if multipeerSession.connectedPeers.count > 3{
            print("There's some player wants to join but the limitation of peers, it can't join the battle")
            return false
        }
        else{
            return true
        }
        
    }
    func peerJoined(_ peer: PeerID){
        print("A Player wants to join hold it")
        
        //provide it the session ID to the new user so they can your track the anchors
    }
    
    func peerLeft(_ peer:PeerID){
        guard let multipeerSession = multipeerSession else { return}
        
        print("The player \(peer) is leaving the game")
        
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
            print("Deferred sending collaboration to later because there are no peers")
        }
    }
}
