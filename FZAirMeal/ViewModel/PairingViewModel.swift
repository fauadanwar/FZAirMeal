//
//  PairingViewModel.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import Foundation

class PairingViewModel
{
    var peers: [PeerDevice] = []
    private let mealManager = MealDataManager()
    private let passengerManager = PassengerDataManager()

    init() {
        PersistentStorage.shared.resetAllCoreData()
        mealManager.getMealRecord { result in
            print(result ?? "empty meals")
        }
        passengerManager.getPassengerRecord { result in
            print(result ?? "empty Passenger")
        }
    }
}
