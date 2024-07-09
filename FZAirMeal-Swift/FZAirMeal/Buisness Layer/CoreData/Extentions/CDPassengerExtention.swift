//
//  CDPassengerExtention.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

extension CDPassenger: CDRecord {
    
    typealias T = Passenger
    
    func convertToRecord() -> Passenger? {
        guard let id, let name, let seatNumber else { return nil }
        if let orderId = toOrder?.id
        {
            return Passenger(id: id, name: name, seatNumber: seatNumber, orderId: orderId)
        }
        else
        {
            return Passenger(id: id, name: name, seatNumber: seatNumber, orderId: nil)
        }
    }
}
