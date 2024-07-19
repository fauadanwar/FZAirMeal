//
//  PassengerViewModel.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import Foundation
import Combine

protocol PassengerViewModelDelegate: AnyObject
{
    func passengerDataUpdated()
}

protocol PassengerViewModelProtocol {
    var passengerViewModelDelegate: PassengerViewModelDelegate? { get set }
    func getPassengersAt(indexPath: IndexPath) -> Passenger?
    func getPassengerAndMealAt(indexPath: IndexPath) -> (Passenger?, Meal?)
    func getPassengerCount() -> Int
}

class PassengerViewModel: PassengerViewModelProtocol {
    
    var passengerManager: PassengerDataManagerProtocol
    weak var passengerViewModelDelegate: PassengerViewModelDelegate?
    
    init(passengerManager: PassengerDataManagerProtocol = PassengerDataManager()) {
        self.passengerManager = passengerManager
        self.passengerManager.passengerDataManagerDelegate = self
    }
    
    func getPassengersAt(indexPath: IndexPath) -> Passenger? {
        return passengerManager.getPassengerAt(indexPath: indexPath)
    }
    
    func getPassengerAndMealAt(indexPath: IndexPath) -> (Passenger?, Meal?) {
        return passengerManager.getPassengerAndMealAt(indexPath: indexPath)
    }
    
    func getPassengerCount() -> Int {
        switch ConnectivityData.shared.pairingRole {
        case .host:
            guard ConnectivityData.shared.isServiceStarted else { return 0 }
            return passengerManager.getPassengerCount()
        case .peer:
            guard let selectedHost = ConnectivityData.shared.selectedHost,
                  selectedHost.connectionStatus == .connected,
                  ConnectivityData.shared.isServiceStarted else { return 0 }
            return passengerManager.getPassengerCount()
        case .unknown:
            return 0
        }
    }
}

extension PassengerViewModel : PassengerDataManagerDelegate
{
    func passengerDataUpdated() {
        passengerViewModelDelegate?.passengerDataUpdated()
    }
}
