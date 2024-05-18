//
//  MealRepositoryProtocol.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

protocol MealRepositoryProtocol {
    func getMealRecords(completionHandler:@escaping(_ result: Array<Meal>?)->Void)
}

protocol MealCoreDataRepositoryProtocol : MealRepositoryProtocol, BaseCoreDataRepository where T == Meal {
    func insertMealRecords(records:Array<Meal>) -> Bool
    func batchInsertMealRecords(records:Array<Meal>) -> Bool
}

protocol MealApiResourceRepositoryProtocol : MealRepositoryProtocol {
    func getMealRecordsFromAPI(completionHandler: @escaping (Array<Meal>?) -> Void)
}
