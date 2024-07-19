//
//  BaseCoreDataRepositoryProtocol.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

protocol BaseCoreDataRepositoryProtocol {

    associatedtype CDT where CDT: NSFetchRequestResult, CDT: NSManagedObject, CDT: CDRecord
    associatedtype T where T: Record
    
    func create(record: T) -> Bool
    func getAll() -> [T]
    func get(byIdentifier id: String) -> T?
    func update(record: T) -> Bool
    func delete(byIdentifier id: String) -> Bool
    func assignProperties(record: T, cdRecord: CDT)
    func updateProperties(record: T, cdRecord: CDT)
    func getCDRecord(byIdentifier id: String) -> CDT?
}

extension BaseCoreDataRepositoryProtocol {
    
    func create(record: T) -> Bool {
        let cdRecord = CDT(context: PersistentStorage.shared.context)
        assignProperties(record: record, cdRecord: cdRecord)
        return PersistentStorage.shared.saveContext()
    }

    func getAll() -> [CDT.T] {
        let result = PersistentStorage.shared.fetchManagedObject(managedObject: CDT.self)
        var records : [CDT.T] = []
        result?.forEach({ (cdRecord) in
            if let record = cdRecord.convertToRecord() {
                records.append(record)
            }
        })
        return records
    }

    func get(byIdentifier id: String) -> CDT.T? {
        guard let result = getCDRecord(byIdentifier: id) else {return nil}
        return result.convertToRecord()
    }
    
    func update(record: T) -> Bool {
        guard let cdRecord = getCDRecord(byIdentifier: record.id) else {return false}
        updateProperties(record: record, cdRecord: cdRecord)
        return PersistentStorage.shared.saveContext()
    }

    func delete(byIdentifier id: String) -> Bool {
        guard let cdRecord = getCDRecord(byIdentifier: id) else {return false}
        PersistentStorage.shared.context.delete(cdRecord)
        return PersistentStorage.shared.saveContext()
    }
    
    func getCDRecord(byIdentifier id: String) -> CDT?
    {
        let fetchRequest = NSFetchRequest<CDT>(entityName: String(describing: CDT.self))
        let predicate = NSPredicate(format: "id==%@", id as CVarArg)
        fetchRequest.predicate = predicate
        do {
            guard let result = try PersistentStorage.shared.context.fetch(fetchRequest).first else {return nil}
            return result
        } catch let error {
            debugPrint(error)
        }
        return nil
    }
    
    func resetCoreData() {
        PersistentStorage.shared.resetCoreData(entityName: String(describing: CDT.self))
    }
    
    func resetAllCoreData() {
        PersistentStorage.shared.resetAllCoreData()
    }
}
