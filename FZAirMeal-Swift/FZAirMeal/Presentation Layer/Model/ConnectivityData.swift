//
//  PairingType.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 17/07/24.
//

import Foundation

enum PairingRole {
    case host
    case peer
    case unknown
}

class ConnectivityData: ObservableObject {
    @Published var pairingRole: PairingRole = .unknown {
        didSet {
            isServiceStarted = false
        }
    }
    
    @Published var isServiceStarted: Bool = false {
        didSet {
            if !isServiceStarted {
                selectedHost = nil
                availabelHosts = []
                requestingPairingDevice = nil
                joinedPeer = []
            }
        }
    }
    @Published var ifFetchingData: Bool = false

    // Properties for Host
    @Published var requestingPairingDevice: PairingDevice?
    @Published var joinedPeer: [PairingDevice] = []
    
    // Properties for Peer
    @Published var selectedHost: PairingDevice?
    @Published var availabelHosts: [PairingDevice] = []
    
    static let shared = ConnectivityData()
    private init() {}
}
