//
//  MealProvider.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import Foundation
import CoreData

// Usage example for CDMeal
class MealProvider: CoreDataProvider<CDMeal> {
    init(delegate: NSFetchedResultsControllerDelegate) {
        super.init(with: delegate)
    }
}

