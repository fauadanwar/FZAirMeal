//
//  MealDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

protocol MealDataManagerDelegate: AnyObject
{
    func mealDataUpdated()
}

class MealDataManager {

    private let _cdMealDataRepository: any MealCoreDataRepositoryProtocol
    private let _mealResourceRepository: any MealResourceRepositoryProtocol
    weak var mealDataManagerDelegate: MealDataManagerDelegate?

    init(_cdMealDataRepository: any MealCoreDataRepositoryProtocol = MealCoreDataRepository(), _mealResourceRepository: any MealResourceRepositoryProtocol = MealResourceRepository()) {
        self._cdMealDataRepository = _cdMealDataRepository
        self._mealResourceRepository = _mealResourceRepository
    }
    
    func getMealRecord(completionHandler:@escaping(_ result: Array<Meal>?)-> Void) {
        let response = _cdMealDataRepository.getAll()
        if(response.count != 0) {
            // return response to the view controller
            completionHandler(response)
        }
        else
        {
            completionHandler(nil)
        }
    }
    
    func getMealRecordForPeer(completionHandler:@escaping(_ result: Array<Meal>?)-> Void) {
        completionHandler(nil)
    }
    
    func getMealRecordForHost(completionHandler:@escaping(_ result: Array<Meal>?)-> Void) {
        // get data from api
        _mealResourceRepository.getRecordsFromAPI {[weak self] apiResponse in
            guard let self else { return }
            if(apiResponse != nil && apiResponse?.count != 0) {
                // insert record in core data
                _ = _cdMealDataRepository.batchInsertMealRecords(records: apiResponse!)
                completionHandler(apiResponse)
            }
            else {
                // get data from file
                _mealResourceRepository.getRecords { [weak self] apiResponse in
                    guard let self else { return }
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
    
    func getMealsCount() -> Int {
        return _cdMealDataRepository.getMealsCount()
    }
    
    func getMealAt(indexPath: IndexPath) -> Meal? {
        return _cdMealDataRepository.getMealAt(indexPath: indexPath)
    }
    
    func getMealWith(mealid: String) -> Meal? {
        return _cdMealDataRepository.get(byIdentifier: mealid)
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

extension MealDataManager : MealCoreDataRepositoryDelegate
{
    func mealsDataUpdated() {
        mealDataManagerDelegate?.mealDataUpdated()
    }
}
