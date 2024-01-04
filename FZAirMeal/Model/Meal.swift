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
    var quantity: Int
    let cost: Double
    
    init(id: String, name: String, details: String?, quantity: Int, cost: Double) {
        self.id = id
        self.name = name
        self.details = details
        self.quantity = quantity
        self.cost = cost
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case details
        case quantity
        case cost
    }
}

struct MealResponse: Decodable {
    let errorMessage: String?
    let meals: [Meal]?

    enum CodingKeys: String, CodingKey {
        case meals
        case errorMessage
    }
}
