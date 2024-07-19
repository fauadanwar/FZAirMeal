//
//  PeerConnectionManager.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation
import MultipeerConnectivity

protocol PeerConnectionManagerProtocol {
    var peerConnectionManagerDelegate: PeerConnectionManagerDelegate? { get set }
    func startBrowsing()
    func stopBrowsing()
    func resetState()
    func resetAllCoreData()
    func connectToHost(host: PairingDevice)
}

protocol PeerConnectionManagerDelegate: AnyObject {
    func foundHost(host: PairingDevice)
    func lostHost(host: PairingDevice)
}

class PeerConnectionManager: NSObject, PeerConnectionManagerProtocol {
    var peerRepository: PeerConnectionRepositoryProtocol
    weak var peerConnectionManagerDelegate: PeerConnectionManagerDelegate?

    init(peerRepository: PeerConnectionRepositoryProtocol = PeerConnectionRepository.shared) {
        self.peerRepository = peerRepository
        super.init()
        self.peerRepository.peerConnectionRepositoryDelegate = self
    }
    
    func startBrowsing() {
        peerRepository.startBrowsing()
    }
    
    func stopBrowsing() {
        peerRepository.stopBrowsing()
    }
    
    func resetState() {
        peerRepository.resetState()
    }
    
    func resetAllCoreData()
    {
        peerRepository.resetAllCoreData()
    }
    
    func connectToHost(host: PairingDevice) {
        peerRepository.connectToHost(host: host)
    }
}


extension PeerConnectionManager: PeerConnectionRepositoryDelegate {
    func foundHost(host: PairingDevice) {
        peerConnectionManagerDelegate?.foundHost(host: host)
    }
    
    func lostHost(host: PairingDevice) {
        peerConnectionManagerDelegate?.lostHost(host: host)
    }
}
