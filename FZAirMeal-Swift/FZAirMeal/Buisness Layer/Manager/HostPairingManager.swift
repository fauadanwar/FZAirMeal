//
//  HostPairingManager.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 05/07/24.
//

import Foundation
import MultipeerConnectivity

class HostPairingManager: NSObject, ObservableObject {
    var hostRepository: HostPairingRepositoryProtocol
    
    @Published var requetingPairingDevice: PairingDevice?
    @Published var joinedPeer: [PairingDevice] = []
    
    init(hostRepository: HostPairingRepositoryProtocol = HostPairingRepository()) {
        self.hostRepository = hostRepository
        super.init()
        self.hostRepository.hostPairingRepositoryDelegate = self
    }
    
    func startHosting() {
        hostRepository.startAdvertising()
    }
    
    func stopHosting() {
        hostRepository.stopAdvertising()
    }
    
    func resetAllCoreData()
    {
        hostRepository.resetAllCoreData()
    }
    
    func resetState() {
        hostRepository.resetState()
        requetingPairingDevice = nil
        joinedPeer.removeAll()
    }

    func sendData<T: Record>(_ object: T, type: SendDataType, toPeer: PairingDevice) -> Bool {
        return hostRepository.sendData(object, type: type, toPeer: toPeer)
    }
    
    func brodcastData<T: Record>(_ object: T, type: SendDataType) -> Bool {
        return hostRepository.brodcastData(object, type: type)
    }
}

extension HostPairingManager: HostPairingRepositoryDelegate {
    func didReceivePairingRequest(pairingDevice: PairingDevice) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            requetingPairingDevice = pairingDevice
        }
    }
    
    func grantPermisson(pairingDevice: PairingDevice, permission: Bool) {
        hostRepository.grantPermisson(pairingDevice: pairingDevice, permission: permission)
        if permission {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                joinedPeer.append(pairingDevice)
            }
        }
    }
}
