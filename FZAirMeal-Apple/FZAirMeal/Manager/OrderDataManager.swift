//
//  OrderDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

struct OrderDataManager
{
    private let _cdOrderRepository : any OrderRepositoryProtocol = OrderCoreDataRepository()

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

}

