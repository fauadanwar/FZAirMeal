//
//  PassengerProvider.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import Foundation
import CoreData

class PassengerProvider
{
    private weak var fetchedResultControllerDelegate: NSFetchedResultsControllerDelegate?

    init(With fetchedResultControllerDelegate: NSFetchedResultsControllerDelegate)
    {
        self.fetchedResultControllerDelegate = fetchedResultControllerDelegate
    }

    lazy var fetchedResultController: NSFetchedResultsController<CDPassenger> =
        {
            let fetchRequest: NSFetchRequest<CDPassenger> = CDPassenger.fetchRequest()
            fetchRequest.fetchBatchSize = 20
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

            let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistentStorage.shared.context, sectionNameKeyPath: nil, cacheName: nil)

            controller.delegate = fetchedResultControllerDelegate

            do{
                 try controller.performFetch()
            } catch{
                debugPrint(error)
            }

            return controller
    }()

}
