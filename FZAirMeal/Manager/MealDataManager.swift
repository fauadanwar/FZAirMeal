//
//  MealDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

struct MealDataManager {

    private let _cdMealDataRepository : any MealCoreDataRepositoryProtocol = MealCoreDataRepository()
    private let _mealApiRepository: MealApiResourceRepositoryProtocol = MealApiResourceRepository()

    func getMealRecord(completionHandler:@escaping(_ result: Array<Meal>?)-> Void) {

        _cdMealDataRepository.getMealRecords { response in
            if(response != nil && response?.count != 0){
                // return response to the view controller
                completionHandler(response)

            }else {
                // call the api
                _mealApiRepository.getMealRecords { apiResponse in
                    if(apiResponse != nil && apiResponse?.count != 0){

                        // insert record in core data
                      _ = _cdMealDataRepository.batchInsertMealRecords(records: apiResponse!)
                        completionHandler(apiResponse)
                    }
                }
            }
        }
    }
    
    func deleteMeal(byIdentifier id: String) -> Bool
    {
        return _cdMealDataRepository.delete(byIdentifier: id)
    }

    func updateMeal(record: Meal) -> Bool
    {
        return _cdMealDataRepository.update(record: record)
    }

}
