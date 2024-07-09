//
//  PermitionRequest.swift
//  FZAirMeal
//
//  Created by Fanwar on 05/01/24.
//

import Foundation
import MultipeerConnectivity

struct PairingRequest: Identifiable {
    let id: MCPeerID
    let onRequest: (Bool) -> Void?
}
