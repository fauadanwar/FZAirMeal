//
//  OrderProvider.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import Foundation
import CoreData

// Usage example for other entities
class OrderProvider: CoreDataProvider<CDOrder> {
    init(delegate: NSFetchedResultsControllerDelegate) {
        super.init(with: delegate)
    }
}
