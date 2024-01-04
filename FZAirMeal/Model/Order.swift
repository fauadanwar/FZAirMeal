//
//  Order.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

class Order: Record, Hashable, Codable {
    
    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let passenger: Passenger
    let meal: Meal
    let time: Date
    
    init(id: String, passenger: Passenger, meal: Meal, time: Date) {
        self.id = id
        self.passenger = passenger
        self.meal = meal
        self.time = time
    }
    
    func data() -> Data? {
      let encoder = JSONEncoder()
      return try? encoder.encode(self)
    }
}
