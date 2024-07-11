//
//  Meal.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

class Meal: Record, Hashable, Codable{
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let name: String
    let details: String?
    let quantity: Int
    let cost: Double
    var orderedQuantity: Int
    
    init(id: String, name: String, details: String?, quantity: Int, cost: Double, orderedQuantity: Int) {
        self.id = id
        self.name = name
        self.details = details
        self.quantity = quantity
        self.cost = cost
        self.orderedQuantity = orderedQuantity
    }
    
    func data() -> Data? {
      let encoder = JSONEncoder()
      return try? encoder.encode(self)
    }
}
