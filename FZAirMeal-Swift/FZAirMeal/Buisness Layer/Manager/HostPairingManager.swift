//
//  HostPairingManager.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 05/07/24.
//

import Foundation
import MultipeerConnectivity

protocol HostPairingManagerProtocol {
    var hostPairingManagerDelegate: HostPairingManagerDelegate? { get set }
    func startHosting()
    func stopHosting()
    func resetAllCoreData()
    func resetState()
    func sendData<T: Record>(_ object: T, type: SendDataType, toPeer: PairingDevice) -> Bool
    func brodcastData<T: Record>(_ object: T, type: SendDataType) -> Bool
    func grantPermisson(pairingDevice: PairingDevice, permission: Bool)
}

protocol HostPairingManagerDelegate: AnyObject{
    func didReceivePairingRequest(pairingDevice: PairingDevice)
}

class HostPairingManager: NSObject, HostPairingManagerProtocol {
    var hostRepository: HostPairingRepositoryProtocol
    weak var hostPairingManagerDelegate: HostPairingManagerDelegate?
    
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
    }
    
    func sendData<T: Record>(_ object: T, type: SendDataType, toPeer: PairingDevice) -> Bool {
        return hostRepository.sendData(object, type: type, toPeer: toPeer)
    }
    
    func brodcastData<T: Record>(_ object: T, type: SendDataType) -> Bool {
        return hostRepository.brodcastData(object, type: type)
    }
    
    func grantPermisson(pairingDevice: PairingDevice, permission: Bool) {
        hostRepository.grantPermisson(pairingDevice: pairingDevice, permission: permission)
    }
}

extension HostPairingManager: HostPairingRepositoryDelegate {
    func didReceivePairingRequest(pairingDevice: PairingDevice) {
        hostPairingManagerDelegate?.didReceivePairingRequest(pairingDevice: pairingDevice)
    }
}
