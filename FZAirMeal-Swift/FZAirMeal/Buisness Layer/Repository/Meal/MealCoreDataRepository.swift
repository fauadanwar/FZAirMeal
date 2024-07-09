//
//  MealCoreDataRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

protocol MealCoreDataRepositoryProtocol: BaseCoreDataRepositoryProtocol where T == Meal {
    func insertMealRecords(records:Array<Meal>) -> Bool
    func batchInsertMealRecords(records:Array<Meal>) -> Bool
}

struct MealCoreDataRepository : MealCoreDataRepositoryProtocol {

    typealias T = Meal
    typealias CDT = CDMeal
    
    func batchInsertMealRecords(records: Array<Meal>) -> Bool {
        PersistentStorage.shared.persistentContainer.performBackgroundTask { privateManagedContext in

            // batch inserts
            let request = self.createBatchInsertRequest(records: records)
            do{
                try privateManagedContext.execute(request)
            }catch {
                debugPrint("batch insert error")
            }
        }

        return true

    }

    private func createBatchInsertRequest(records:Array<Meal>) -> NSBatchInsertRequest {

        let totalCount = records.count
        var index = 0

        let batchInsert = NSBatchInsertRequest(entity: CDMeal.entity()) { (managedObject: NSManagedObject) -> Bool in

            guard index < totalCount else {return true}

            if let meal = managedObject as? CDMeal {
                let data = records[index]
                meal.id = data.id
                meal.name = data.name
                meal.details = data.details
                meal.cost = data.cost
                meal.quantity = Int16(data.quantity)
            }
            
            index  += 1
            return false
        }

        return batchInsert

    }

    func insertMealRecords(records: Array<Meal>) -> Bool {

        debugPrint("MealDataRepository: Insert record operation is starting")

        PersistentStorage.shared.persistentContainer.performBackgroundTask { privateManagedContext in
            //insert code
            records.forEach { mealRecord in
                let cdMeal = CDMeal(context: privateManagedContext)
                cdMeal.id = mealRecord.id
                cdMeal.name = mealRecord.name
                cdMeal.details = mealRecord.details
                cdMeal.cost = mealRecord.cost
                cdMeal.quantity = Int16(mealRecord.quantity)
            }

            if(privateManagedContext.hasChanges){
                try? privateManagedContext.save()
                debugPrint("MealDataRepository: Insert record operation is completed")
            }
        }

        return true
    }
    
    func updateProperties(record: Meal, cdRecord: CDMeal) {
        cdRecord.name = record.name
        cdRecord.details = record.details
        cdRecord.cost = record.cost
        cdRecord.quantity = Int16(record.quantity)
    }
    
    func assignProperties(record: Meal, cdRecord: CDMeal) {
        cdRecord.id = record.id
        cdRecord.name = record.name
        cdRecord.details = record.details
        cdRecord.cost = record.cost
        cdRecord.quantity = Int16(record.quantity)
    }
}
