//
//  CDOrderExtention.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

extension CDOrder: CDRecord {
    
    typealias T = Order

    func convertToRecord() -> Order? {
        guard let id, let passengerId = toPassenger?.id, let mealId = toMeal?.id, let time else { return nil }
        return Order(id: id, passengerId: passengerId, mealId: mealId, time: time)
    }
}
