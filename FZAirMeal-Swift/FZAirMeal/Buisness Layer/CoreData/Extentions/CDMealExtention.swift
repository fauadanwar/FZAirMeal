//
//  CDMealExtention.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

extension CDMeal: CDRecord {
    
    typealias T = Meal
    
    func convertToRecord() -> Meal? {
        guard let id, let name else { return nil }
        return Meal(id: id, name: name, details: self.details, quantity: Int(self.quantity), cost: self.cost, orderedQuantity: Int(self.orderedQuantity))
    }
}
