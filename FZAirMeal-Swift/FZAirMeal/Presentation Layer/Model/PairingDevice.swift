//
//  PairingDevice.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation
import MultipeerConnectivity

class PairingDevice: Identifiable, Hashable, ObservableObject {
    
    static func == (lhs: PairingDevice, rhs: PairingDevice) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: MCPeerID
    @Published var connectionStatus: MCSessionState = .notConnected
    
    init(id: MCPeerID) {
        self.id = id
        self.connectionStatus = connectionStatus
    }
}
