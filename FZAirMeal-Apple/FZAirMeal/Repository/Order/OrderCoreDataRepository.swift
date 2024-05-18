//
//  OrderCoreDataRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

struct OrderCoreDataRepository : OrderRepositoryProtocol
{
    typealias T = Order
    typealias CDT = CDOrder
    
    func assignProperties(record: Order, cdRecord: CDOrder) {
        cdRecord.id = record.id
        cdRecord.time = record.time

        let _cdMealDataRepository = MealCoreDataRepository()
        if let cdMeal = _cdMealDataRepository.getCDRecord(byIdentifier: record.meal.id)
        {
            cdMeal.quantity -= 1
            cdRecord.toMeal = cdMeal
        }
        
        let _cdPassengerDataRepository = PassengerCoreDataRepository()
        if let cdPassenger = _cdPassengerDataRepository.getCDRecord(byIdentifier: record.passenger.id)
        {
            cdPassenger.toOrder = cdRecord
            cdRecord.toPassenger = cdPassenger
        }
    }
    
    func updateProperties(record: Order, cdRecord: CDOrder) {
        cdRecord.time = record.time

        cdRecord.toMeal?.name = record.meal.name
        cdRecord.toMeal?.details = record.meal.details
        cdRecord.toMeal?.cost = record.meal.cost
        cdRecord.toMeal?.quantity = Int16(record.meal.quantity)

        cdRecord.toPassenger?.name = record.passenger.name
        cdRecord.toPassenger?.seatNumber = record.passenger.seatNumber
    }
    
    func delete(byIdentifier id: String) -> Bool {
        guard let cdRecord = getCDRecord(byIdentifier: id) else {return false}
        guard let mealId = cdRecord.toMeal?.id else { return false }
        let _cdMealDataRepository = MealCoreDataRepository()
        if let cdMeal = _cdMealDataRepository.getCDRecord(byIdentifier: mealId)
        {
            cdMeal.quantity += 1
        }
        PersistentStorage.shared.context.delete(cdRecord)
        return PersistentStorage.shared.saveContext()
    }
}
