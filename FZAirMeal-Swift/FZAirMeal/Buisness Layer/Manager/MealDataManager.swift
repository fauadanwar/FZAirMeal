//
//  MealDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

struct MealDataManager {

    private let _cdMealDataRepository: any MealCoreDataRepositoryProtocol
    private let _mealResourceRepository: any MealResourceRepositoryProtocol

    init(_cdMealDataRepository: any MealCoreDataRepositoryProtocol = MealCoreDataRepository(), _mealResourceRepository: any MealResourceRepositoryProtocol = MealResourceRepository()) {
        self._cdMealDataRepository = _cdMealDataRepository
        self._mealResourceRepository = _mealResourceRepository
    }
    
    func getMealRecordForPeer(completionHandler:@escaping(_ result: Array<Meal>?)-> Void) {
        completionHandler(nil)
    }
    
    func getMealRecordForHost(completionHandler:@escaping(_ result: Array<Meal>?)-> Void) {
        let response = _cdMealDataRepository.getAll()
        if(response.count != 0) {
            // return response to the view controller
            completionHandler(response)
        }
        else {
            // get data from api
            _mealResourceRepository.getRecordsFromAPI { apiResponse in
                if(apiResponse != nil && apiResponse?.count != 0){
                    // insert record in core data
                    _ = _cdMealDataRepository.batchInsertMealRecords(records: apiResponse!)
                    completionHandler(apiResponse)
                }
                else {
                    // get data from file
                    _mealResourceRepository.getRecords { apiResponse in
                        if(apiResponse != nil && apiResponse?.count != 0){
                            // insert record in core data
                            _ = _cdMealDataRepository.batchInsertMealRecords(records: apiResponse!)
                            completionHandler(apiResponse)
                        }
                        else {
                            completionHandler(nil)
                        }
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
    
    func resetCoreData()
    {
        return _cdMealDataRepository.resetCoreData()
    }
}
