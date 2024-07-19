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

protocol MealViewModelProtocol {
    var mealViewModelDelegate: MealViewModelDelegate? { get set }
    func sendOrder(order: Order) -> Bool
    func getMealAt(indexPath: IndexPath) -> Meal?
    func getMealsCount() -> Int
    func getPassengerWith(passengerID: String) -> Passenger?
}

class MealViewModel: MealViewModelProtocol
{
    private let orderDataManager: OrderDataManagerProtocol
    private var mealDataManager: MealDataManagerProtocol
    private var passengerDataManager: PassengerDataManagerProtocol
    weak var mealViewModelDelegate: MealViewModelDelegate?

    init(orderDataManager: OrderDataManagerProtocol = OrderDataManager(),
         mealDataManager: MealDataManagerProtocol = MealDataManager(),
         passengerDataManager: PassengerDataManagerProtocol = PassengerDataManager())
    {
        self.orderDataManager = orderDataManager
        self.mealDataManager = mealDataManager
        self.passengerDataManager = passengerDataManager
        self.mealDataManager.mealDataManagerDelegate = self
    }
    
    func sendOrder(order: Order) -> Bool {
        ConnectivityData.shared.ifFetchingData = true
        if let meal = mealDataManager.getMealWith(mealid: order.mealId),
           meal.quantity - meal.orderedQuantity > 0 {
            switch ConnectivityData.shared.pairingRole {
            case .host:
                return orderDataManager.createAndSendOrderToPeers(order: order)
            case .peer:
                guard let selectedHost = ConnectivityData.shared.selectedHost else { return false }
                return orderDataManager.sendOrderToHost(order: order, toHost: selectedHost)
            case .unknown:
                return false
            }
        }
        return false
    }
    
    func getMealAt(indexPath: IndexPath) -> Meal? {
        return mealDataManager.getMealAt(indexPath: indexPath)
    }
    
    func getMealsCount() -> Int {
        return mealDataManager.getMealsCount()
    }
    
    func getPassengerWith(passengerID: String) -> Passenger? {
        passengerDataManager.getPassengerWith(passengerId: passengerID)
    }
}

extension MealViewModel : MealDataManagerDelegate
{
    func mealDataUpdated() {
        mealViewModelDelegate?.mealDataUpdated()
    }
}
