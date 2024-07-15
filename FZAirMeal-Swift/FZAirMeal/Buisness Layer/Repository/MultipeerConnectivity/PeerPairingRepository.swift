//
//  PeerPairingRepository.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation
import MultipeerConnectivity

protocol PeerPairingRepositoryProtocol: BasePairingRepositoryProtocol {
    var peerPairingRepositoryDelegate: PeerPairingRepositoryDelegate? { get set }
    func startBrowsing()
    func stopBrowsing()
    func resetState()
    func connectToHost(host: PairingDevice)
    func sendData<T: Record>(_ object: T, type: SendDataType, toHost: PairingDevice) -> Bool
}

protocol PeerPairingRepositoryDelegate: AnyObject{
    func foundHost(host: PairingDevice)
    func lostHost(host: PairingDevice)
}

class PeerPairingRepository: NSObject, PeerPairingRepositoryProtocol {
    private let serviceType = "air-meal"
    private let browser: MCNearbyServiceBrowser
    let session: MCSession
    weak var peerPairingRepositoryDelegate: PeerPairingRepositoryDelegate?
    @Published var hosts: [PairingDevice] = []
    
    static let shared = PeerPairingRepository()

    private override init() {
        let peer = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peer)
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        super.init()
        browser.delegate = self
        session.delegate = self
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
        session.disconnect()
    }
    
    func resetState() {
        stopBrowsing()
        hosts.removeAll()
    }
    
    func connectToHost(host: PairingDevice) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            browser.invitePeer(host.id, to: session, withContext: nil, timeout: 60)
        }
    }
    
    func sendData<T: Record>(_ object: T, type: SendDataType, toHost: PairingDevice) -> Bool {
        do {
            let wrapper = try DataWrapper(type: type, object: object)
            let data = try JSONEncoder().encode(wrapper)
            try session.send(data, toPeers: [toHost.id], with: .reliable)
            return true
        } catch {
            print("Error sending data: \(error.localizedDescription)")
            return false
        }
    }
}

extension PeerPairingRepository: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if hosts.contains(where: { $0.id == peerID }) {
                return
            }
            let pairingDevice = PairingDevice(id: peerID)
            hosts.append(pairingDevice)
            peerPairingRepositoryDelegate?.foundHost(host: pairingDevice)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let index = hosts.firstIndex(where: { $0.id == peerID }) {
                peerPairingRepositoryDelegate?.lostHost(host: hosts[index])
                hosts.remove(at: index)
            }
        }
    }
}

extension PeerPairingRepository: MCSessionDelegate
{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let host = hosts.first(where: { $0.id == peerID }) {
                host.connectionStatus = state
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
                let orders = try JSONDecoder().decode([Order].self, from: wrapper.data)
            case .passengers:
                let passengers = try JSONDecoder().decode([Passenger].self, from: wrapper.data)
            case .meals:
                let meals = try JSONDecoder().decode([Meal].self, from: wrapper.data)
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
