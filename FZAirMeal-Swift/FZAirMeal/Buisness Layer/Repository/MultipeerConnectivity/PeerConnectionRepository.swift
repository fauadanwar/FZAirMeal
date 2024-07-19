//
//  PeerConnectionRepository.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation
import MultipeerConnectivity

protocol PeerConnectionRepositoryProtocol: BasePairingRepositoryProtocol {
    var peerConnectionRepositoryDelegate: PeerConnectionRepositoryDelegate? { get set }
    func startBrowsing()
    func stopBrowsing()
    func resetState()
    func connectToHost(host: PairingDevice)
    func sendData<T: Record>(_ object: T, type: SendDataType, toHost: PairingDevice) -> Bool
    func sendResquestForMeals(toHost: PairingDevice, completionHandler:@escaping(_ result: Array<Meal>?) -> Void)
    func sendResquestForOrders(toHost: PairingDevice, completionHandler:@escaping(_ result: Array<Order>?) -> Void)
    func sendResquestForPassengers(toHost: PairingDevice, completionHandler:@escaping(_ result: Array<Passenger>?) -> Void)
}

protocol PeerConnectionRepositoryDelegate: AnyObject{
    func foundHost(host: PairingDevice)
    func lostHost(host: PairingDevice)
}

class PeerConnectionRepository: NSObject, PeerConnectionRepositoryProtocol {
    private let serviceType = "air-meal"
    private let browser: MCNearbyServiceBrowser
    let session: MCSession
    weak var peerConnectionRepositoryDelegate: PeerConnectionRepositoryDelegate?
    var hosts: [PairingDevice] = []
    private let cdOrderDataRepository: any OrderCoreDataRepositoryProtocol = OrderCoreDataRepository.shared

    //make optional completion handlers for passengers, orders and meals
    var completionHandlerPassengers: ((_ result: Array<Passenger>?) -> Void)?
    var completionHandlerOrders: ((_ result: Array<Order>?) -> Void)?
    var completionHandlerMeals: ((_ result: Array<Meal>?) -> Void)?

    static let shared = PeerConnectionRepository()

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
    
    //write the function to send request for passengers
    func sendResquestForPassengers(toHost: PairingDevice, completionHandler:@escaping(_ result: Array<Passenger>?) -> Void) {
        do {
            let wrapper = DataWrapper(type: .passengers)
            let data = try JSONEncoder().encode(wrapper)
            try session.send(data, toPeers: [toHost.id], with: .reliable)
            completionHandlerPassengers = completionHandler
        } catch {
            print("Error sending data: \(error.localizedDescription)")
            completionHandler(nil)
        }
    }
    //Write the function to send request for orders
    func sendResquestForOrders(toHost: PairingDevice, completionHandler:@escaping(_ result: Array<Order>?) -> Void) {
        do {
            let wrapper = DataWrapper(type: .orders)
            let data = try JSONEncoder().encode(wrapper)
            try session.send(data, toPeers: [toHost.id], with: .reliable)
            completionHandlerOrders = completionHandler
        } catch {
            print("Error sending data: \(error.localizedDescription)")
            completionHandler(nil)
        }
    }
    //write the function to send request for meals
    func sendResquestForMeals(toHost: PairingDevice, completionHandler:@escaping(_ result: Array<Meal>?) -> Void) {
        do {
            let wrapper = DataWrapper(type: .meals)
            let data = try JSONEncoder().encode(wrapper)
            try session.send(data, toPeers: [toHost.id], with: .reliable)
            completionHandlerMeals = completionHandler
        } catch {
            print("Error sending data: \(error.localizedDescription)")
            completionHandler(nil)
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

extension PeerConnectionRepository: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if hosts.contains(where: { $0.id == peerID }) {
                return
            }
            let pairingDevice = PairingDevice(id: peerID)
            hosts.append(pairingDevice)
            peerConnectionRepositoryDelegate?.foundHost(host: pairingDevice)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let index = hosts.firstIndex(where: { $0.id == peerID }) {
                peerConnectionRepositoryDelegate?.lostHost(host: hosts[index])
                hosts.remove(at: index)
            }
        }
    }
}

extension PeerConnectionRepository: MCSessionDelegate
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
            if let data = wrapper.data {
                switch wrapper.type {
                case .orders:
                    let orders = try JSONDecoder().decode([Order].self, from: data)
                    completionHandlerOrders?(orders)
                case .passengers:
                    let passengers = try JSONDecoder().decode([Passenger].self, from: data)
                    completionHandlerPassengers?(passengers)
                case .meals:
                    let meals = try JSONDecoder().decode([Meal].self, from: data)
                    completionHandlerMeals?(meals)
                case .order:
                    let order = try JSONDecoder().decode(Order.self, from: data)
                    //add order to core data
                    _ = cdOrderDataRepository.create(record: order)
                case .deleteOrder:
                    let order = try JSONDecoder().decode(Order.self, from: data)
                    //delete order from core data
                    _ = cdOrderDataRepository.delete(byIdentifier: order.id)
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
