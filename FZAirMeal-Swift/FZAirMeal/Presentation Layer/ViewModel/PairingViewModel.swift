//
//  PairingViewModel.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import Foundation
import Combine

protocol PairingViewModelProtocol {
    func grantPermisson(requetingPairingDevice: PairingDevice, permission: Bool)
    func clearAllData()
    func fetchData(ofType type: SendDataType)
}

class PairingViewModel: NSObject, ObservableObject, PairingViewModelProtocol
{
    private var mealManager: MealDataManagerProtocol
    private var passengerManager: PassengerDataManagerProtocol
    private var orderDataManager: OrderDataManagerProtocol
    private var peerConnectionManager: PeerConnectionManagerProtocol
    private var hostConnectionManager: HostConnectionManagerProtocol
        
    var subscriptions = Set<AnyCancellable>()
    
    init(mealManager: MealDataManagerProtocol = MealDataManager(),
         passengerManager: PassengerDataManagerProtocol = PassengerDataManager(),
         orderDataManager: OrderDataManagerProtocol = OrderDataManager(),
         peerConnectionManager: PeerConnectionManagerProtocol = PeerConnectionManager(),
         hostConnectionManager: HostConnectionManagerProtocol = HostConnectionManager())
    {
        self.mealManager = mealManager
        self.passengerManager = passengerManager
        self.orderDataManager = orderDataManager
        self.peerConnectionManager = peerConnectionManager
        self.hostConnectionManager = hostConnectionManager
        
        super.init()

        ConnectivityData.shared.$selectedHost
            .receive(on: DispatchQueue.main)
            .sink { selectedHost in
                guard let selectedHost else { return }
                peerConnectionManager.connectToHost(host: selectedHost)
            }
            .store(in: &subscriptions)
        
        ConnectivityData.shared.$isServiceStarted
            .receive(on: DispatchQueue.main)
            .sink { pairingRole in
                hostConnectionManager.resetState()
                peerConnectionManager.resetState()
                
                switch ConnectivityData.shared.pairingRole {
                case .host:
                    if ConnectivityData.shared.isServiceStarted {
                        hostConnectionManager.startHosting()
                    }
                    else {
                        hostConnectionManager.stopHosting()
                    }
                case .peer:
                    if ConnectivityData.shared.isServiceStarted {
                        peerConnectionManager.startBrowsing()
                    }
                    else {
                        peerConnectionManager.stopBrowsing()
                    }
                case .unknown:
                    hostConnectionManager.stopHosting()
                    peerConnectionManager.stopBrowsing()
                    print("Switch Should be disabled")
                }
            }
            .store(in: &subscriptions)
        self.peerConnectionManager.peerConnectionManagerDelegate = self
        self.hostConnectionManager.hostConnectionManagerDelegate = self
    }
    
    func grantPermisson(requetingPairingDevice: PairingDevice, permission: Bool) {
        hostConnectionManager.grantPermisson(pairingDevice: requetingPairingDevice, permission: permission)
        if permission {
            DispatchQueue.main.async {
                ConnectivityData.shared.joinedPeer.append(requetingPairingDevice)
            }
        }
    }
    
    func fetchData(ofType type: SendDataType) {
        ConnectivityData.shared.ifFetchingData = true
        switch ConnectivityData.shared.pairingRole {
        case .host:
            switch type {
            case .passengers:
                passengerManager.getPassengerRecordForHost { result in
                    print(result ?? "empty Passenger")
                    ConnectivityData.shared.ifFetchingData = false
                }
            case .meals:
                mealManager.getMealRecordForHost { result in
                    print(result ?? "empty meals")
                    ConnectivityData.shared.ifFetchingData = false
                }
            default:
                print("Host dose not require to fetch/send order data")
            }
        case .peer:
            guard let selectedHost = ConnectivityData.shared.selectedHost else {
                print("host not selected")
                return
            }
            switch type {
            case .orders:
                orderDataManager.getOrderRecordForPeer(host: selectedHost) { result in
                    print(result ?? "empty Order")
                    ConnectivityData.shared.ifFetchingData = false
                }
            case .passengers:
                passengerManager.getPassengerRecordForPeer(host: selectedHost) { result in
                    print(result ?? "empty Passenger")
                    ConnectivityData.shared.ifFetchingData = false
                }
            case .meals:
                mealManager.getMealRecordForPeer(host: selectedHost) { result in
                    print(result ?? "empty meals")
                    ConnectivityData.shared.ifFetchingData = false
                }
            default:
                print("Peer dose not require to send order data")
            }
        case .unknown:
            break
        }
    }
    
    func clearAllData() {
        switch ConnectivityData.shared.pairingRole {
        case .host:
            hostConnectionManager.resetAllCoreData()
        case .peer:
            peerConnectionManager.resetAllCoreData()
        case .unknown:
            print("Button should be hidden")
        }
    }
}

extension PairingViewModel: HostConnectionManagerDelegate {
    func didReceivePairingRequest(pairingDevice: PairingDevice) {
        DispatchQueue.main.async {
            ConnectivityData.shared.requestingPairingDevice = pairingDevice
        }
    }
}

extension PairingViewModel: PeerConnectionManagerDelegate {
    func foundHost(host: PairingDevice) {
        DispatchQueue.main.async {
            if ConnectivityData.shared.availabelHosts.contains(host) {
                return
            }
            ConnectivityData.shared.availabelHosts.append(host)
        }
    }
    
    func lostHost(host: PairingDevice) {
        DispatchQueue.main.async {
            if let index = ConnectivityData.shared.availabelHosts.firstIndex(of: host) {
                ConnectivityData.shared.availabelHosts.remove(at: index)
            }
        }
    }
}
