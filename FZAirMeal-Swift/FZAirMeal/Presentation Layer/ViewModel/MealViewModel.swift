//
//  MealViewModel.swift
//  FZAirMeal
//
//  Created by Fanwar on 05/01/24.
//

import Foundation

protocol MealViewModelDelegate: AnyObject
{
    func mealDataUpdated()
}

class MealViewModel
{
    private let orderDataManager: OrderDataManager
    private let mealDataManager: MealDataManager
    weak var mealViewModelDelegate: MealViewModelDelegate?

    init(orderDataManager: OrderDataManager = OrderDataManager(), mealDataManager: MealDataManager = MealDataManager()) {
        self.orderDataManager = orderDataManager
        self.mealDataManager = mealDataManager
    }
    
    func placeOrder(order: Order) -> Bool {
        return orderDataManager.create(record: order)
    }
    
    func cancelOrder(orderId: String) -> Bool {
        return orderDataManager.deleteOrder(byIdentifier: orderId)
    }
    func getMealAt(indexPath: IndexPath) -> Meal? {
        return mealDataManager.getMealAt(indexPath: indexPath)
    }
    
    func getMealsCount() -> Int {
        return mealDataManager.getMealsCount()
    }
}

extension MealViewModel : MealDataManagerDelegate
{
    func mealDataUpdated() {
        mealViewModelDelegate?.mealDataUpdated()
    }
}
