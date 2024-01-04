//
//  MealViewModel.swift
//  FZAirMeal
//
//  Created by Fanwar on 05/01/24.
//

import Foundation
class MealViewModel
{
    private let orderDataManager = OrderDataManager()
    func placeOrder(order: Order) -> Bool {
        return orderDataManager.create(record: order)
    }
}
