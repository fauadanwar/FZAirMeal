//
//  HostConnectionManager.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 05/07/24.
//

import Foundation
import MultipeerConnectivity

protocol HostConnectionManagerProtocol {
    var hostConnectionManagerDelegate: HostConnectionManagerDelegate? { get set }
    func startHosting()
    func stopHosting()
    func resetAllCoreData()
    func resetState()
    func brodcastData<T: Record>(_ object: T, type: SendDataType) -> Bool
    func grantPermisson(pairingDevice: PairingDevice, permission: Bool)
}

protocol HostConnectionManagerDelegate: AnyObject{
    func didReceivePairingRequest(pairingDevice: PairingDevice)
}

class HostConnectionManager: NSObject, HostConnectionManagerProtocol {
    var hostRepository: HostConnectionRepositoryProtocol
    weak var hostConnectionManagerDelegate: HostConnectionManagerDelegate?
    
    init(hostRepository: HostConnectionRepositoryProtocol = HostConnectionRepository.shared) {
        self.hostRepository = hostRepository
        super.init()
        self.hostRepository.hostConnectionRepositoryDelegate = self
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
    
    func brodcastData<T: Record>(_ object: T, type: SendDataType) -> Bool {
        return hostRepository.brodcastData(object, type: type)
    }
    
    func grantPermisson(pairingDevice: PairingDevice, permission: Bool) {
        hostRepository.grantPermisson(pairingDevice: pairingDevice, permission: permission)
    }
}

extension HostConnectionManager: HostConnectionRepositoryDelegate {
    func didReceivePairingRequest(pairingDevice: PairingDevice) {
        hostConnectionManagerDelegate?.didReceivePairingRequest(pairingDevice: pairingDevice)
    }
}
