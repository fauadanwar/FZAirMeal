//
//  PairingViewModel.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import Foundation
import Combine

enum PairingRole {
    case host
    case peer
    case unknown
}

class PairingViewModel: NSObject, ObservableObject
{
    var mealManager: MealDataManagerProtocol
    var passengerManager: PassengerDataManagerprotocol
    var orderDataManager: OrderDataManagerprotocol
    var peerPairingManager: PeerPairingManagerProtocol
    var hostPairingManager: HostPairingManagerProtocol
    
    init(mealManager: MealDataManagerProtocol = MealDataManager(),
         passengerManager: PassengerDataManagerprotocol = PassengerDataManager(),
         orderDataManager: OrderDataManagerprotocol = OrderDataManager(),
         peerPairingManager: PeerPairingManagerProtocol = PeerPairingManager(),
         hostPairingManager: HostPairingManagerProtocol = HostPairingManager()) 
    {
        self.mealManager = mealManager
        self.passengerManager = passengerManager
        self.orderDataManager = orderDataManager
        self.peerPairingManager = peerPairingManager
        self.hostPairingManager = hostPairingManager
        
        super.init()

        self.peerPairingManager.peerPairingManagerDelegate = self
        self.hostPairingManager.hostPairingManagerDelegate = self
    }
    
    @Published var ifFetchingData: Bool = false
    
    @Published var pairingRole: PairingRole = .unknown {
        didSet {
            isServiceStarted = false
        }
    }
    
    @Published var isServiceStarted: Bool = false {
        didSet {
            hostPairingManager.resetState()
            peerPairingManager.resetState()
            switch pairingRole {
            case .host:
                if isServiceStarted {
                    hostPairingManager.startHosting()
                }
                else {
                    hostPairingManager.stopHosting()
                }
            case .peer:
                if isServiceStarted {
                    peerPairingManager.startBrowsing()
                }
                else {
                    peerPairingManager.stopBrowsing()
                }
            case .unknown:
                hostPairingManager.stopHosting()
                peerPairingManager.stopBrowsing()
                print("Switch Should be disabled")
            }
        }
    }
    
    // Properties for Host
    @Published var requetingPairingDevice: PairingDevice?
    @Published var joinedPeer: [PairingDevice] = []
    
    // Properties for Peer
    @Published var selectedHost: PairingDevice? {
        didSet {
            if let selectedHost {
                peerPairingManager.connectToHost(host: selectedHost)
            }
        }
    }
    @Published var availabelHosts: [PairingDevice] = []
    
    var subscriptions = Set<AnyCancellable>()
    
    func grantPermisson(requetingPairingDevice: PairingDevice, permission: Bool) {
        hostPairingManager.grantPermisson(pairingDevice: requetingPairingDevice, permission: permission)
        if permission {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                joinedPeer.append(requetingPairingDevice)
            }
        }
    }
    
    func fetchData(ofType type: SendDataType) {
        ifFetchingData = true
        switch pairingRole {
        case .host:
            switch type {
            case .passengers:
                passengerManager.getPassengerRecordForHost { [weak self] result in
                    guard let self else { return }
                    print(result ?? "empty Passenger")
                    ifFetchingData = false
                }
            case .meals:
                mealManager.getMealRecordForHost { [weak self] result in
                    guard let self else { return }
                    print(result ?? "empty meals")
                    ifFetchingData = false
                }
            default:
                print("Host dose not require to fetch order data")
            }
        case .peer:
            switch type {
            case .orders:
                orderDataManager.getOrderRecordForPeer { [weak self] result in
                    guard let self else { return }
                    print(result ?? "empty Order")
                    ifFetchingData = false
                }
            case .passengers:
                passengerManager.getPassengerRecordForPeer { [weak self] result in
                    guard let self else { return }
                    print(result ?? "empty Passenger")
                    ifFetchingData = false
                }
            case .meals:
                mealManager.getMealRecordForPeer { [weak self] result in
                    guard let self else { return }
                    print(result ?? "empty meals")
                    ifFetchingData = false
                }
            }
        case .unknown:
            break
        }
    }
    
    func clearAllData() {
        switch pairingRole {
        case .host:
            hostPairingManager.resetAllCoreData()
        case .peer:
            peerPairingManager.resetAllCoreData()
        case .unknown:
            print("Button should be hidden")
        }
    }
}

extension PairingViewModel: HostPairingManagerDelegate {
    func didReceivePairingRequest(pairingDevice: PairingDevice) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            requetingPairingDevice = pairingDevice
        }
    }
}

extension PairingViewModel: PeerPairingManagerDelegate {
    func foundHost(host: PairingDevice) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if availabelHosts.contains(host) {
                return
            }
            availabelHosts.append(host)
        }
    }
    
    func lostHost(host: PairingDevice) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let index = availabelHosts.firstIndex(of: host) {
                availabelHosts.remove(at: index)
            }
        }
    }
}
