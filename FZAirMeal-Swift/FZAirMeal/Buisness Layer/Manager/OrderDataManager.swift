//
//  OrderDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

protocol OrderDataManagerDelegate: AnyObject
{
    func orderDataUpdated()
}

class OrderDataManager
{
    private let _cdOrderRepository : any OrderRepositoryProtocol
    weak var orderDataManagerDelegate: OrderDataManagerDelegate?

    init(_cdOrderRepository: any OrderRepositoryProtocol = OrderCoreDataRepository()) {
        self._cdOrderRepository = _cdOrderRepository
    }
    
    func create(record: Order) -> Bool
    {
        _cdOrderRepository.create(record: record)
    }

    func deleteOrder(byIdentifier id: String) -> Bool
    {
        return _cdOrderRepository.delete(byIdentifier: id)
    }

    func updateOrder(record: Order) -> Bool
    {
        return _cdOrderRepository.update(record: record)
    }
    
    func resetCoreData()
    {
        return _cdOrderRepository.resetCoreData()
    }
    
    func getOrderRecordForPeer(completionHandler:@escaping(_ result: Array<Order>?)-> Void) {
        completionHandler(nil)
    }
    
    func getOrdersCount() -> Int {
        return _cdOrderRepository.getOrdersCount()
    }
    
    func getOrderAt(indexPath: IndexPath) -> Order? {
        return _cdOrderRepository.getOrderAt(indexPath: indexPath)
    }
    
    func getPassengerMealAndOrderAt(indexPath: IndexPath) -> (Passenger?, Meal?, Order?) {
        return _cdOrderRepository.getPassengerMealAndOrderAt(indexPath: indexPath)
    }
    
    func getOrderWith(orderid: String) -> Order? {
        return _cdOrderRepository.get(byIdentifier: orderid)
    }
    
    func getOrderRecord(completionHandler:@escaping(_ result: Array<Order>?)-> Void) {
        let response = _cdOrderRepository.getAll()
        if(response.count != 0) {
            // return response to the view controller
            completionHandler(response)
        }
        else
        {
            completionHandler(nil)
        }
    }
}

extension OrderDataManager: OrderCoreDataRepositoryDelegate {
    func orderDataUpdated() {
        orderDataManagerDelegate?.orderDataUpdated()
    }
}
