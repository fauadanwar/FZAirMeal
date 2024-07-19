//
//  MealDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

protocol MealDataManagerProtocol {
    var mealDataManagerDelegate: MealDataManagerDelegate? { get set }
    func getMealRecordForPeer(host: PairingDevice, completionHandler:@escaping(_ result: Array<Meal>?)-> Void)
    func getMealRecordForHost(completionHandler:@escaping(_ result: Array<Meal>?)-> Void)
    func getMealRecord() -> Array<Meal>?
    func getMealsCount() -> Int
    func getMealAt(indexPath: IndexPath) -> Meal?
    func getMealWith(mealid: String) -> Meal?
    func deleteMeal(byIdentifier id: String) -> Bool
    func updateMeal(record: Meal) -> Bool
    func resetCoreData()
}

protocol MealDataManagerDelegate: AnyObject
{
    func mealDataUpdated()
}

class MealDataManager: MealDataManagerProtocol {

    private var _cdMealDataRepository: any MealCoreDataRepositoryProtocol
    private let _mealResourceRepository: any MealResourceRepositoryProtocol
    weak var mealDataManagerDelegate: MealDataManagerDelegate?

    init(_cdMealDataRepository: any MealCoreDataRepositoryProtocol = MealCoreDataRepository.shared, _mealResourceRepository: any MealResourceRepositoryProtocol = MealResourceRepository.shared) {
        self._cdMealDataRepository = _cdMealDataRepository
        self._mealResourceRepository = _mealResourceRepository
        self._cdMealDataRepository.mealCoreDataRepositoryDelegate = self
    }
    
    func getMealRecord() -> Array<Meal>? {
        let response = _cdMealDataRepository.getAll()
        if(response.count != 0) {
            return response
        }
        else {
            return nil
        }
    }
    
    func getMealRecordForPeer(host: PairingDevice, completionHandler:@escaping(_ result: Array<Meal>?)-> Void) {
        _mealResourceRepository.getMealRecordsFromHost(host: host) { [weak self] meals in
            guard let meals = meals,
                  let self,
                  meals.count > 0 else {
                completionHandler(nil)
                return
            }
            // insert record in core data
            _ = _cdMealDataRepository.batchInsertMealRecords(records: meals)
            completionHandler(meals)
        }
    }
    
    func getMealRecordForHost(completionHandler:@escaping(_ result: Array<Meal>?)-> Void) {
        // get data from api
        _mealResourceRepository.getRecordsFromAPI {[weak self] apiResponse in
            guard let self else { return }
            if let apiResponse,
               apiResponse.count > 0 {
                // insert record in core data
                _ = _cdMealDataRepository.batchInsertMealRecords(records: apiResponse)
                completionHandler(apiResponse)
            }
            else {
                // get data from file
                _mealResourceRepository.getRecords { [weak self] fileResponse in
                    guard let self else { return }
                    if let fileResponse,
                       fileResponse.count > 0 {
                        // insert record in core data
                        _ = _cdMealDataRepository.batchInsertMealRecords(records: fileResponse)
                        completionHandler(fileResponse)
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
