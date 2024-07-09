//
//  OrderCoreDataRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

protocol OrderRepositoryProtocol: BaseCoreDataRepositoryProtocol where T == Order  {
    
}

struct OrderCoreDataRepository : OrderRepositoryProtocol
{
    typealias T = Order
    typealias CDT = CDOrder
    
    func assignProperties(record: Order, cdRecord: CDOrder) {
        cdRecord.id = record.id
        cdRecord.time = record.time

        let _cdMealDataRepository = MealCoreDataRepository()
        if let cdMeal = _cdMealDataRepository.getCDRecord(byIdentifier: record.mealId)
        {
            cdMeal.quantity -= 1
            cdRecord.toMeal = cdMeal
        }
        
        let _cdPassengerDataRepository = PassengerCoreDataRepository()
        if let cdPassenger = _cdPassengerDataRepository.getCDRecord(byIdentifier: record.passengerId)
        {
            cdPassenger.toOrder = cdRecord
            cdRecord.toPassenger = cdPassenger
        }
    }
    
    func updateProperties(record: Order, cdRecord: CDOrder) {
        cdRecord.time = record.time
        cdRecord.toMeal?.id = record.mealId
        cdRecord.toPassenger?.id = record.passengerId
    }
    
    func delete(byIdentifier id: String) -> Bool {
        guard let cdRecord = getCDRecord(byIdentifier: id) else {return false}
        guard let mealId = cdRecord.toMeal?.id else { return false }
        guard let passengerId = cdRecord.toPassenger?.id else { return false }
        let _cdMealDataRepository = MealCoreDataRepository()
        if let cdMeal = _cdMealDataRepository.getCDRecord(byIdentifier: mealId)
        {
            cdMeal.quantity += 1
        }
        let _cdPassengerDataRepository = PassengerCoreDataRepository()
        if let cdPassenger = _cdPassengerDataRepository.getCDRecord(byIdentifier: passengerId)
        {
            cdPassenger.toOrder = nil
        }
        PersistentStorage.shared.context.delete(cdRecord)
        return PersistentStorage.shared.saveContext()
    }
}
