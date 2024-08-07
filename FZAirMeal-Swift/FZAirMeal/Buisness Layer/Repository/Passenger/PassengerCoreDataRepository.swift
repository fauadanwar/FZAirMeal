//
//  PassengerCoreDataRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData
import Combine

protocol PassengerCoreDataRepositoryProtocol: BaseCoreDataRepositoryProtocol where T == Passenger, CDT == CDPassenger {
    var passengerCoreDataRepositoryDelegate: PassengerCoreDataRepositoryDelegate? { get set }
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
    private var cancellables = Set<AnyCancellable>()
    weak var passengerCoreDataRepositoryDelegate: PassengerCoreDataRepositoryDelegate?
    
    lazy var passengerDataProvider: PassengerProvider =
    {
        let dataProvider = PassengerProvider(delegate: self)
        return dataProvider
    }()
    
    static let shared = PassengerCoreDataRepository()
    
    private override init() {
        super.init()
        PersistentStorage.shared.dataClearPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                passengerDataProvider = PassengerProvider(delegate: self)
            }
            .store(in: &cancellables)
        PersistentStorage.shared.dataInsertPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                passengerDataProvider = PassengerProvider(delegate: self)
            }
            .store(in: &cancellables)
    }
    
    func batchInsertPassengerRecords(records: Array<Passenger>) -> Bool {

        PersistentStorage.shared.persistentContainer.performBackgroundTask { privateManagedContext in
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
