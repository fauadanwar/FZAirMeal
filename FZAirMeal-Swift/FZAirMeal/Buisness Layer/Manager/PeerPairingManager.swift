//
//  PeerPairingManager.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation
import MultipeerConnectivity


class PeerPairingManager: NSObject {
    var peerRepository: PeerPairingRepositoryProtocol
    @Published var hosts: [PairingDevice] = []

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
        hosts.removeAll()
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
        if hosts.contains(host) {
            return
        }
        hosts.append(host)
    }
    
    func lostHost(host: PairingDevice) {
        if let index = hosts.firstIndex(of: host) {
            hosts.remove(at: index)
        }
    }
}
