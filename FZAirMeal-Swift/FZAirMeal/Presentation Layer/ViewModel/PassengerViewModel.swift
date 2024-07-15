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

class PassengerViewModel{
    
    var passengerManager: PassengerDataManagerprotocol
    weak var passengerViewModelDelegate: PassengerViewModelDelegate?
    
    init(passengerManager: PassengerDataManagerprotocol = PassengerDataManager()) {
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
        return passengerManager.getPassengerCount()
    }
}

extension PassengerViewModel : PassengerDataManagerDelegate
{
    func passengerDataUpdated() {
        passengerViewModelDelegate?.passengerDataUpdated()
    }
}
