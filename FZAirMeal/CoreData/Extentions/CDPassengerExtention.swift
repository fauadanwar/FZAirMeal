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
        if let toOrder,
           let orderId = toOrder.id,
           let meal = toOrder.toMeal?.convertToRecord(),
           let time = toOrder.time
        {
            let passenger = Passenger(id: id, name: name, seatNumber: seatNumber, Order: nil)
            let order = Order(id: orderId, passenger: passenger, meal: meal, time: time)
            return Passenger(id: id, name: name, seatNumber: seatNumber, Order: order)
        }
        else
        {
            return Passenger(id: id, name: name, seatNumber: seatNumber, Order: nil)
        }
    }
}
