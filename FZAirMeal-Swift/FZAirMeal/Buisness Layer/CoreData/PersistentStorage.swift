//
//  PersistentStorage.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData
import Combine

final class PersistentStorage {
    
    init() {}
    
    static let shared = PersistentStorage()
    
    let dataClearPublisher = PassthroughSubject<Void, Never>()
    let dataInsertPublisher = PassthroughSubject<Void, Never>()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FZAirMeal")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    lazy var context = persistentContainer.viewContext

    func saveContext () -> Bool {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
            }
        }
        return true
    }
    
    func executeedInsert() {
        self.dataInsertPublisher.send(())
    }
    
    func fetchManagedObject<T: NSManagedObject>(managedObject: T.Type) -> [T]?
    {
        do {
            guard let result = try context.fetch(managedObject.fetchRequest()) as? [T] else {return nil}
            
            return result

        } catch let error {
            debugPrint(error)
        }

        return nil
    }
    
    func resetCoreData(entityName: String) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
            self.context.reset()
            self.context.refreshAllObjects()
        } catch let error as NSError{
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func resetAllCoreData() {

         // get all entities and loop over them
         let entityNames = self.persistentContainer.managedObjectModel.entities.map({ $0.name!})
         entityNames.forEach { [weak self] entityName in
             
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

            do {
                try self?.context.execute(deleteRequest)
                try self?.context.save()
                self?.context.reset()
                self?.context.refreshAllObjects()
                self?.dataClearPublisher.send(())
            } catch let error as NSError{
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func printDocumentDirectoryPath() {
       debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
    }
}
