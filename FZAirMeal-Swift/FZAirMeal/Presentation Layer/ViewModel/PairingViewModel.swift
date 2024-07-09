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
    var mealManager = MealDataManager()
    var passengerManager = PassengerDataManager()
    var orderDataManager = OrderDataManager()
    var peerPairingManager = PeerPairingManager()
    var hostPairingManager = HostPairingManager()
    
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
    
    override init() {
        super.init()
        hostPairingManager.$requetingPairingDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pairingDevice in
                guard let self, let pairingDevice else { return }
                self.requetingPairingDevice = pairingDevice
            }
            .store(in: &subscriptions)
        
        peerPairingManager.$hosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hosts in
                guard let self else { return }
                self.availabelHosts = hosts
            }
            .store(in: &subscriptions)
        
        hostPairingManager.$joinedPeer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] joinedPeer in
                guard let self else { return }
                self.joinedPeer = joinedPeer
            }
            .store(in: &subscriptions)
    }
    
    func grantPermisson(requetingPairingDevice: PairingDevice, permission: Bool) {
        hostPairingManager.grantPermisson(pairingDevice: requetingPairingDevice, permission: permission)
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
        orderDataManager.resetCoreData()
    }
}
