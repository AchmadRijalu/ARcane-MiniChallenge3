//
//  PlayerModel.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 21/08/23.
//

import MultipeerSession
import MultipeerConnectivity
import SwiftUI

class PlayerModel: ObservableObject {
    @Published var peerId: MCPeerID
	@Published var health:Int
	@Published var statusLevel:String
	
	init(peerId: MCPeerID, health: Int, statusLevel: String) {
		self.peerId = peerId
		self.health = health
		self.statusLevel = statusLevel
	}
}
