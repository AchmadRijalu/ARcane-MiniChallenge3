//
//  PlayerModel.swift
//  ARcane-MiniChallenge3
//
//  Created by Achmad Rijalu on 21/08/23.
//

import Foundation
import MultipeerSession
import MultipeerConnectivity


struct PlayerModel {
    var peerId: MCPeerID
    var health:Int
    var statusLevel:String
}
