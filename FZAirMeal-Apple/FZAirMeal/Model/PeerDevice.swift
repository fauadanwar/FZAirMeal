//
//  PeerDevice.swift
//  FZAirMeal
//
//  Created by Fanwar on 05/01/24.
//

import Foundation
import MultipeerConnectivity

struct PeerDevice: Identifiable, Hashable {
    let id = UUID()
    let peerId: MCPeerID
}
