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
    private let orderDataManager: OrderDataManagerprotocol
    private var mealDataManager: MealDataManagerProtocol
    weak var mealViewModelDelegate: MealViewModelDelegate?

    init(orderDataManager: OrderDataManagerprotocol = OrderDataManager(), mealDataManager: MealDataManagerProtocol = MealDataManager()) {
        self.orderDataManager = orderDataManager
        self.mealDataManager = mealDataManager
        self.mealDataManager.mealDataManagerDelegate = self
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
