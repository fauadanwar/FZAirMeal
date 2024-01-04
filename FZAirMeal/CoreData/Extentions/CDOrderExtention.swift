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
        guard let id, let passenger = toPassenger?.convertToRecord(), let meal = toMeal?.convertToRecord(), let time else { return nil }
        return Order(id: id, passenger: passenger, meal: meal, time: time)
    }
}
