//
//  PairingViewModel.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import Foundation
import MultipeerConnectivity
import Combine

class PairingViewModel: NSObject, ObservableObject
{
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    private let session: MCSession
    private let serviceType = "air-meal"
    
    private let mealManager = MealDataManager()
    private let passengerManager = PassengerDataManager()
    private let orderDataManager = OrderDataManager()

    @Published var permissionRequest: PermitionRequest?
    
    @Published var selectedPeer: PeerDevice? {
        didSet {
            connect()
        }
    }
    @Published var peers: [PeerDevice] = []
    @Published var joinedPeer: [PeerDevice] = []

    @Published var isAdvertised: Bool = false {
        didSet {
            isAdvertised ? advertiser.startAdvertisingPeer() : advertiser.stopAdvertisingPeer()
        }
    }
    var subscriptions = Set<AnyCancellable>()

    override init() {
        PersistentStorage.shared.resetAllCoreData()
        mealManager.getMealRecord { result in
            print(result ?? "empty meals")
        }
        passengerManager.getPassengerRecord { result in
            print(result ?? "empty Passenger")
        }
        let peer = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peer)
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: peer,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        super.init()
        advertiser.delegate = self
        browser.delegate = self
        session.delegate = self
    }
    
    func send(order: Order) -> Bool {
        
        guard let data = order.data() else {
            print("Unabel to parse order to data")
            return false
        }
        do {
            if let peerId = joinedPeer.last?.peerId
            {
                try session.send(data, toPeers: [peerId], with: .reliable)
                return true
            }
            else {
                print("No Joined peer present to send order")
                return false
            }
        } catch let error {
            print("Error sending data \(error.localizedDescription)")
            return false
        }
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func finishBrowsing() {
        browser.stopBrowsingForPeers()
    }
    
    func show(peerId: MCPeerID) {
        guard let first = peers.first(where: { $0.peerId == peerId }) else {
            return
        }
        
        joinedPeer.append(first)
    }
    
    private func connect() {
        guard let selectedPeer else {
            return
        }
        
        if session.connectedPeers.contains(selectedPeer.peerId) {
            joinedPeer.append(selectedPeer)
        } else {
            browser.invitePeer(selectedPeer.peerId, to: session, withContext: nil, timeout: 60)
        }
    }
}

extension PairingViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        permissionRequest = PermitionRequest(
            peerId: peerID,
            onRequest: { [weak self] permission in
                invitationHandler(permission, permission ? self?.session : nil)
            }
        )
    }
}

extension PairingViewModel: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        peers.append(PeerDevice(peerId: peerID))
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peers.removeAll(where: { $0.peerId == peerID })
    }
}

extension PairingViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Sync orders with other peers bases on pending orders time and last order sync time")
        case .notConnected:
            print("Not connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting to: \(peerID.displayName)")
        @unknown default:
            print("Unknown state: \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let last = joinedPeer.last, last.peerId == peerID, let order = try? JSONDecoder().decode(Order.self, from: data)  else {
            return
        }
        //Add code handling for failuer cases like item become out of stock.
        _ = orderDataManager.create(record: order)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //
    }
}
