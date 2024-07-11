//
//  PassengerCoreDataRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

protocol PassengerCoreDataRepositoryProtocol: BaseCoreDataRepositoryProtocol where T == Passenger {
    func insertPassengerRecords(records:Array<Passenger>) -> Bool
    func batchInsertPassengerRecords(records:Array<Passenger>) -> Bool
    func getPassengersAt(indexPath: IndexPath) -> Passenger?
    func getPassengerAndMealAt(indexPath: IndexPath) ->  (Passenger?, Meal?)
    func getPassengerCount() -> Int
}

protocol PassengerCoreDataRepositoryDelegate: AnyObject
{
    func passengerDataUpdated()
}

class PassengerCoreDataRepository: NSObject, PassengerCoreDataRepositoryProtocol {
    typealias T = Passenger
    typealias CDT = CDPassenger
    weak var passengerCoreDataRepositoryDelegate: PassengerCoreDataRepositoryDelegate?
    
    lazy var passengerDataProvider: PassengerProvider =
    {
        PersistentStorage.shared.printDocumentDirectoryPath()
        let dataProvider = PassengerProvider(delegate: self)
        return dataProvider
    }()
    
    func batchInsertPassengerRecords(records: Array<Passenger>) -> Bool {

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

    private func createBatchInsertRequest(records:Array<Passenger>) -> NSBatchInsertRequest {

        let totalCount = records.count
        var index = 0

        let batchInsert = NSBatchInsertRequest(entity: CDPassenger.entity()) { (managedObject: NSManagedObject) -> Bool in

            guard index < totalCount else {return true}

            if let passenger = managedObject as? CDPassenger {
                let data = records[index]
                passenger.id = data.id
                passenger.name = data.name
                passenger.seatNumber = data.seatNumber
            }
            
            index  += 1
            return false
        }

        return batchInsert

    }

    func insertPassengerRecords(records: Array<Passenger>) -> Bool {

        debugPrint("PassengerDataRepository: Insert record operation is starting")

        PersistentStorage.shared.persistentContainer.performBackgroundTask { privateManagedContext in
            //insert code
            records.forEach { passengerRecord in
                let cdPassenger = CDPassenger(context: privateManagedContext)
                cdPassenger.id = passengerRecord.id
                cdPassenger.name = passengerRecord.name
                cdPassenger.seatNumber = passengerRecord.seatNumber
            }

            if(privateManagedContext.hasChanges){
                try? privateManagedContext.save()
                debugPrint("PassengerDataRepository: Insert record operation is completed")
            }
        }

        return true
    }
    
    func getPassengersAt(indexPath: IndexPath) -> Passenger? {
        let cdPassenger = passengerDataProvider.fetchedResultsController.object(at: indexPath)
        return cdPassenger.convertToRecord()
    }
    
    func getPassengerAndMealAt(indexPath: IndexPath) ->  (Passenger?, Meal?) {
        let cdPassenger = passengerDataProvider.fetchedResultsController.object(at: indexPath)
        return (cdPassenger.convertToRecord(), cdPassenger.toOrder?.toMeal?.convertToRecord())
    }
    
    func getPassengerCount() -> Int {
        passengerDataProvider.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func updateProperties(record: Passenger, cdRecord: CDPassenger) {
        cdRecord.name = record.name
        cdRecord.seatNumber = record.seatNumber
    }
    
    func assignProperties(record: Passenger, cdRecord: CDPassenger) {
        cdRecord.id = record.id
        cdRecord.name = record.name
        cdRecord.seatNumber = record.seatNumber
        cdRecord.toOrder = nil
    }
}

extension PassengerCoreDataRepository : NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        passengerCoreDataRepositoryDelegate?.passengerDataUpdated()
    }
}
