//
//  HostPairingRepository.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation
import MultipeerConnectivity

protocol HostPairingRepositoryProtocol: BasePairingRepositoryProtocol {
    var hostPairingRepositoryDelegate: HostPairingRepositoryDelegate? { get set }
    func startAdvertising()
    func stopAdvertising()
    func resetState()
    func grantPermisson(pairingDevice: PairingDevice, permission: Bool)
    func brodcastData<T: Record>(_ object: T, type: SendDataType) -> Bool
    func sendData<T: Record>(_ object: T, type: SendDataType, toPeer: PairingDevice) -> Bool
}

protocol HostPairingRepositoryDelegate: AnyObject{
    func didReceivePairingRequest(pairingDevice: PairingDevice)
}

class HostPairingRepository: NSObject, HostPairingRepositoryProtocol {
        
    private let serviceType = "air-meal"
    private let advertiser: MCNearbyServiceAdvertiser
    let session: MCSession
    weak var hostPairingRepositoryDelegate: HostPairingRepositoryDelegate?
    private var pairingRequest: PairingRequest?
    @Published var joinedPeer: [PairingDevice] = []

    static let shared = HostPairingRepository()
    
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
    
    func sendData<T: Record>(_ object: T, type: SendDataType, toPeer: PairingDevice) -> Bool {
        do {
            let wrapper = try DataWrapper(type: type, object: object)
            let data = try JSONEncoder().encode(wrapper)
            try session.send(data, toPeers: [toPeer.id], with: .reliable)
            return true
        } catch {
            print("Error sending data: \(error.localizedDescription)")
            return false
        }
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

extension HostPairingRepository: MCNearbyServiceAdvertiserDelegate {
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
        
        hostPairingRepositoryDelegate?.didReceivePairingRequest(pairingDevice: PairingDevice(id: peerID))
    }
    
    func grantPermisson(pairingDevice: PairingDevice, permission: Bool) {
        if let pairingRequest {
            joinedPeer.append(pairingDevice)
            pairingRequest.onRequest(permission)
        }
    }
}

extension HostPairingRepository: MCSessionDelegate
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
                let orders = try JSONDecoder().decode(Order.self, from: wrapper.data)
            default:
                print("Recived wrong data on Host data")
            }
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
        }
    }
    // Other required MCSessionDelegate methods
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
