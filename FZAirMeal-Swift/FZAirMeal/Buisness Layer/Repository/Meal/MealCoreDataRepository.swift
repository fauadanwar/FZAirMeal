//
//  MealCoreDataRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData
import Combine

protocol MealCoreDataRepositoryProtocol: BaseCoreDataRepositoryProtocol where T == Meal {
    func insertMealRecords(records:Array<Meal>) -> Bool
    func batchInsertMealRecords(records:Array<Meal>) -> Bool
    func getMealAt(indexPath: IndexPath) -> Meal?
    func getMealsCount() -> Int
}

protocol MealCoreDataRepositoryDelegate: AnyObject
{
    func mealsDataUpdated()
}

class MealCoreDataRepository: NSObject, MealCoreDataRepositoryProtocol {

    typealias T = Meal
    typealias CDT = CDMeal
    weak var mealCoreDataRepositoryDelegate: MealCoreDataRepositoryDelegate?
    private var cancellables = Set<AnyCancellable>()

    lazy var mealDataProvider: MealProvider =
    {
        let dataProvider = MealProvider(delegate: self)
        return dataProvider
    }()
    
    override init() {
        super.init()
        PersistentStorage.shared.dataClearPublisher
                   .sink { [weak self] in
                       guard let self = self else { return }
                       mealDataProvider = MealProvider(delegate: self)
                   }
                   .store(in: &cancellables)
        PersistentStorage.shared.dataInsertPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                mealDataProvider = MealProvider(delegate: self)
            }
            .store(in: &cancellables)
    }
    
    func batchInsertMealRecords(records: Array<Meal>) -> Bool {
        PersistentStorage.shared.persistentContainer.performBackgroundTask { [weak self] privateManagedContext in
            guard let self = self else { return }
            // batch inserts
            let request = self.createBatchInsertRequest(records: records)
            do{
                try privateManagedContext.execute(request)
                PersistentStorage.shared.executeedInsert()
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
                meal.orderedQuantity = Int16(data.orderedQuantity)
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
                cdMeal.orderedQuantity = Int16(mealRecord.orderedQuantity)

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
        cdRecord.orderedQuantity = Int16(record.orderedQuantity)
    }
    
    func assignProperties(record: Meal, cdRecord: CDMeal) {
        cdRecord.id = record.id
        cdRecord.name = record.name
        cdRecord.details = record.details
        cdRecord.cost = record.cost
        cdRecord.quantity = Int16(record.quantity)
        cdRecord.orderedQuantity = Int16(record.orderedQuantity)
    }
    
    func getMealAt(indexPath: IndexPath) -> Meal? {
        let cdMeal = mealDataProvider.fetchedResultsController.object(at: indexPath)
        return cdMeal.convertToRecord()
    }
    
    func getMealsCount() -> Int {
        mealDataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
    }
}


extension MealCoreDataRepository : NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mealCoreDataRepositoryDelegate?.mealsDataUpdated()
    }
}
