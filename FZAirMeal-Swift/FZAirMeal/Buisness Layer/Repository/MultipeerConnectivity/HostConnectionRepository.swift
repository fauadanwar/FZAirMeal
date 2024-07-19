//
//  HostConnectionRepository.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation
import MultipeerConnectivity

protocol HostConnectionRepositoryProtocol: BasePairingRepositoryProtocol {
    var hostConnectionRepositoryDelegate: HostConnectionRepositoryDelegate? { get set }
    func startAdvertising()
    func stopAdvertising()
    func resetState()
    func grantPermisson(pairingDevice: PairingDevice, permission: Bool)
    func brodcastData<T: Record>(_ object: T, type: SendDataType) -> Bool
}

protocol HostConnectionRepositoryDelegate: AnyObject{
    func didReceivePairingRequest(pairingDevice: PairingDevice)
}

class HostConnectionRepository: NSObject, HostConnectionRepositoryProtocol {
        
    private let serviceType = "air-meal"
    private let advertiser: MCNearbyServiceAdvertiser
    let session: MCSession
    weak var hostConnectionRepositoryDelegate: HostConnectionRepositoryDelegate?
    private var pairingRequest: PairingRequest?
    var joinedPeer: [PairingDevice] = []
    private let cdOrderDataRepository: any OrderCoreDataRepositoryProtocol = OrderCoreDataRepository.shared
    private let cdPassengerDataRepository: any PassengerCoreDataRepositoryProtocol = PassengerCoreDataRepository.shared
    private let cdMealDataRepository: any MealCoreDataRepositoryProtocol = MealCoreDataRepository.shared

    static let shared = HostConnectionRepository()
    
    private override init() {
        let peer = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peer)
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        super.init()
        advertiser.delegate = self
        session.delegate = self
    }

    func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
        session.disconnect()
    }
    
    func resetState() {
        stopAdvertising()
        pairingRequest = nil
        joinedPeer.removeAll()
    }
    
    func brodcastData<T: Record>(_ object: T, type: SendDataType) -> Bool {
        do {
            let wrapper = try DataWrapper(type: type, object: object)
            let data = try JSONEncoder().encode(wrapper)
            let toPeers = joinedPeer.map {$0.id}
            try session.send(data, toPeers: toPeers, with: .reliable)
            return true
        } catch {
            print("Error sending data: \(error.localizedDescription)")
            return false
        }
    }
}

extension HostConnectionRepository: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
       
        guard !joinedPeer.contains(where: { $0.id == peerID }) else {
            invitationHandler(true, session)
            return
        }
        
        self.pairingRequest = PairingRequest(
            id: peerID,
            onRequest: { [weak self] permission in
                guard let self else { return }
                invitationHandler(permission, permission ? session : nil)
            })
        
        hostConnectionRepositoryDelegate?.didReceivePairingRequest(pairingDevice: PairingDevice(id: peerID))
    }
    
    func grantPermisson(pairingDevice: PairingDevice, permission: Bool) {
        if let pairingRequest {
            joinedPeer.append(pairingDevice)
            pairingRequest.onRequest(permission)
        }
    }
}

extension HostConnectionRepository: MCSessionDelegate
{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let peer = joinedPeer.first(where: { $0.id == peerID }) {
                peer.connectionStatus = state
            }
        }
        switch state {
        case .connected:
            print("connected: \(peerID.displayName)")
        case .notConnected:
            print("Not connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting to: \(peerID.displayName)")
        @unknown default:
            print("Unknown state: \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let wrapper = try JSONDecoder().decode(DataWrapper.self, from: data)
            switch wrapper.type {
            case .orders:
                let wrapper = try DataWrapper(type: .orders, objects: cdOrderDataRepository.getAll())
                let data = try JSONEncoder().encode(wrapper)
                try session.send(data, toPeers: [peerID], with: .reliable)
            case .passengers:
                let wrapper = try DataWrapper(type: .passengers, objects: cdPassengerDataRepository.getAll())
                let data = try JSONEncoder().encode(wrapper)
                try session.send(data, toPeers: [peerID], with: .reliable)
            case .meals:
                let wrapper = try DataWrapper(type: .meals, objects: cdMealDataRepository.getAll())
                let data = try JSONEncoder().encode(wrapper)
                try session.send(data, toPeers: [peerID], with: .reliable)
            case .order:
                if let data = wrapper.data {
                    let order = try JSONDecoder().decode(Order.self, from: data)
                    guard cdOrderDataRepository.create(record: order) else { return }
                    _ = brodcastData(order, type: .order)
                }
            case .deleteOrder:
                if let data = wrapper.data {
                    let order = try JSONDecoder().decode(Order.self, from: data)
                    guard cdOrderDataRepository.delete(byIdentifier: order.id) else { return }
                    _ = brodcastData(order, type: .order)
                }
            }
        } catch {
            print("Error decoding data: \(error)")
        }
    }
    // Other required MCSessionDelegate methods
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
