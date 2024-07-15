//
//  PeerPairingManager.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation
import MultipeerConnectivity

protocol PeerPairingManagerProtocol {
    var peerPairingManagerDelegate: PeerPairingManagerDelegate? { get set }
    func startBrowsing()
    func stopBrowsing()
    func resetState()
    func resetAllCoreData()
    func connectToHost(host: PairingDevice)
    func sendOrder(order: Order, type: SendDataType, toHost: PairingDevice) -> Bool
}

protocol PeerPairingManagerDelegate: AnyObject {
    func foundHost(host: PairingDevice)
    func lostHost(host: PairingDevice)
}

class PeerPairingManager: NSObject, PeerPairingManagerProtocol {
    var peerRepository: PeerPairingRepositoryProtocol
    weak var peerPairingManagerDelegate: PeerPairingManagerDelegate?

    init(peerRepository: PeerPairingRepositoryProtocol = PeerPairingRepository()) {
        self.peerRepository = peerRepository
        super.init()
        self.peerRepository.peerPairingRepositoryDelegate = self
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

    func sendOrder(order: Order, type: SendDataType, toHost: PairingDevice) -> Bool {
        return peerRepository.sendData(order, type: type, toHost: toHost)
    }
}


extension PeerPairingManager: PeerPairingRepositoryDelegate {
    func foundHost(host: PairingDevice) {
        peerPairingManagerDelegate?.foundHost(host: host)
    }
    
    func lostHost(host: PairingDevice) {
        peerPairingManagerDelegate?.lostHost(host: host)
    }
}
