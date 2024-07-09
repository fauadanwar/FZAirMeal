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

class PassengerViewModel: ObservableObject {
    
    var passengerManager: PassengerDataManager
    private var cancellables = Set<AnyCancellable>()
    weak var passengerViewModelDelegate: PassengerViewModelDelegate?
    
    init(passengerManager: PassengerDataManager = PassengerDataManager()) {
        self.passengerManager = passengerManager
    }
    
    func getPassengersAt(indexPath: IndexPath) -> Passenger? {
        return passengerManager.getPassengersAt(indexPath: indexPath)
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
