//
//  OrderViewModel.swift
//  FZAirOrder
//
//  Created by Fanwar on 04/01/24.
//

import Foundation

protocol OrderViewModelDelegate: AnyObject
{
    func orderDataUpdated()
}

class OrderViewModel
{
    private var orderDataManager: OrderDataManagerprotocol
    weak var orderViewModelDelegate: OrderViewModelDelegate?
    
    init(orderDataManager: OrderDataManagerprotocol = OrderDataManager()) {
        self.orderDataManager = orderDataManager
        self.orderDataManager.orderDataManagerDelegate = self
    }
    
    func getOrderAt(indexPath: IndexPath) -> Order? {
        return orderDataManager.getOrderAt(indexPath: indexPath)
    }
    
    func getPassengerMealAndOrderAt(indexPath: IndexPath) -> (Passenger?, Meal?, Order?) {
        return orderDataManager.getPassengerMealAndOrderAt(indexPath: indexPath)
    }
    
    func getOrdersCount() -> Int {
        return orderDataManager.getOrdersCount()
    }
}
extension OrderViewModel : OrderDataManagerDelegate
{
    func orderDataUpdated() {
        orderViewModelDelegate?.orderDataUpdated()
    }
}
