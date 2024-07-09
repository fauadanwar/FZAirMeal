//
//  CoreDataProvider.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 09/07/24.
//

import Foundation
import CoreData

class CoreDataProvider<T: NSManagedObject> {
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?

    init(with fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) {
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }

    lazy var fetchedResultsController: NSFetchedResultsController<T> = {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: PersistentStorage.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        controller.delegate = fetchedResultsControllerDelegate

        do {
            try controller.performFetch()
        } catch {
            debugPrint(error)
        }

        return controller
    }()
}
