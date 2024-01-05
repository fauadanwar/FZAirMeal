//
//  PermitionRequest.swift
//  FZAirMeal
//
//  Created by Fanwar on 05/01/24.
//

import Foundation
import MultipeerConnectivity

struct PermitionRequest: Identifiable {
    let id = UUID()
    let peerId: MCPeerID
    let onRequest: (Bool) -> Void
}
