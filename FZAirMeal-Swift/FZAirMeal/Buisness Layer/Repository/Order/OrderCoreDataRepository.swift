//
//  OrderCoreDataRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData
import Combine

protocol OrderRepositoryProtocol: BaseCoreDataRepositoryProtocol where T == Order  {
    func insertOrderRecords(records:Array<Order>) -> Bool
    func batchInsertOrderRecords(records:Array<Order>) -> Bool
    func getOrderAt(indexPath: IndexPath) -> Order?
    func getOrdersCount() -> Int
    func getPassengerMealAndOrderAt(indexPath: IndexPath) -> (Passenger?, Meal?, Order?)
}

protocol OrderCoreDataRepositoryDelegate: AnyObject
{
    func orderDataUpdated()
}

class OrderCoreDataRepository: NSObject, OrderRepositoryProtocol
{
    typealias T = Order
    typealias CDT = CDOrder
    private var cancellables = Set<AnyCancellable>()
    weak var orderCoreDataRepositoryDelegate: OrderCoreDataRepositoryDelegate?
    private let cdPassengerDataRepository: PassengerCoreDataRepository = PassengerCoreDataRepository.shared
    private let cdMealDataRepository: MealCoreDataRepository = MealCoreDataRepository.shared
    
    static let shared = OrderCoreDataRepository()
    
    lazy var orderDataProvider: OrderProvider =
    {
        let dataProvider = OrderProvider(delegate: self)
        return dataProvider
    }()
    
    override init() {
        super.init()
        PersistentStorage.shared.dataClearPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                orderDataProvider = OrderProvider(delegate: self)
            }
            .store(in: &cancellables)
        PersistentStorage.shared.dataInsertPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                orderDataProvider = OrderProvider(delegate: self)
            }
            .store(in: &cancellables)
    }
    
    func batchInsertOrderRecords(records: Array<Order>) -> Bool {
        PersistentStorage.shared.persistentContainer.performBackgroundTask {  [weak self] privateManagedContext in
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

    private func createBatchInsertRequest(records:Array<Order>) -> NSBatchInsertRequest {

        let totalCount = records.count
        var index = 0

        let batchInsert = NSBatchInsertRequest(entity: CDOrder.entity()) { [weak self] (managedObject: NSManagedObject) -> Bool in

            guard let self else { return false }
            guard index < totalCount else {return true}

            if let order = managedObject as? CDOrder {
                let data = records[index]
                order.id = data.id
                order.toPassenger = cdPassengerDataRepository.getCDRecord(byIdentifier: data.passengerId)
                order.toMeal = cdMealDataRepository.getCDRecord(byIdentifier: data.mealId)
                order.time = data.time
            }
            
            index  += 1
            return false
        }

        return batchInsert

    }

    func insertOrderRecords(records: Array<Order>) -> Bool {

        debugPrint("OrderDataRepository: Insert record operation is starting")

        PersistentStorage.shared.persistentContainer.performBackgroundTask { privateManagedContext in
            //insert code
            records.forEach { [weak self] orderRecord in
                guard let self else { return }
                let cdOrder = CDOrder(context: privateManagedContext)
                cdOrder.id = orderRecord.id
                cdOrder.toPassenger = cdPassengerDataRepository.getCDRecord(byIdentifier: orderRecord.passengerId)
                cdOrder.toMeal = cdMealDataRepository.getCDRecord(byIdentifier: orderRecord.mealId)
                cdOrder.time = orderRecord.time
            }

            if(privateManagedContext.hasChanges){
                try? privateManagedContext.save()
                debugPrint("MealDataRepository: Insert record operation is completed")
            }
        }

        return true
    }
    
    func assignProperties(record: Order, cdRecord: CDOrder) {
        cdRecord.id = record.id
        cdRecord.time = record.time

        if let cdMeal = cdMealDataRepository.getCDRecord(byIdentifier: record.mealId)
        {
            cdMeal.orderedQuantity -= 1
            cdRecord.toMeal = cdMeal
        }
        
        if let cdPassenger = cdPassengerDataRepository.getCDRecord(byIdentifier: record.passengerId)
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
        if let cdMeal = cdMealDataRepository.getCDRecord(byIdentifier: mealId)
        {
            cdMeal.orderedQuantity -= 1
        }
        if let cdPassenger = cdPassengerDataRepository.getCDRecord(byIdentifier: passengerId)
        {
            cdPassenger.toOrder = nil
        }
        PersistentStorage.shared.context.delete(cdRecord)
        return PersistentStorage.shared.saveContext()
    }
    
    func getOrderAt(indexPath: IndexPath) -> Order? {
        let cdOrder = orderDataProvider.fetchedResultsController.object(at: indexPath)
        return cdOrder.convertToRecord()
    }
    
    func getPassengerMealAndOrderAt(indexPath: IndexPath) -> (Passenger?, Meal?, Order?) {
        let cdOrder = orderDataProvider.fetchedResultsController.object(at: indexPath)
        let order = cdOrder.convertToRecord()
        let meal = cdOrder.toMeal?.convertToRecord()
        let passenger = cdOrder.toPassenger?.convertToRecord()
        return (passenger, meal, order)
    }
    
    func getOrdersCount() -> Int {
        orderDataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
    }
}

extension OrderCoreDataRepository : NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        orderCoreDataRepositoryDelegate?.orderDataUpdated()
    }
}
