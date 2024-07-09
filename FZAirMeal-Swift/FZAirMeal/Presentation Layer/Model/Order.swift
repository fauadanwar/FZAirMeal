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
    let passengerId: String
    let mealId: String
    let time: Date
    
    init(id: String, passengerId: String, mealId: String, time: Date) {
        self.id = id
        self.passengerId = passengerId
        self.mealId = mealId
        self.time = time
    }
    
    func data() -> Data? {
      let encoder = JSONEncoder()
      return try? encoder.encode(self)
    }
}
