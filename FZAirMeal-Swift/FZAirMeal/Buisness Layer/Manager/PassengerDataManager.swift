//
//  PassengerDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

protocol PassengerDataManagerDelegate: AnyObject
{
    func passengerDataUpdated()
}

class PassengerDataManager {

    private let _cdPassengerDataRepository : any PassengerCoreDataRepositoryProtocol
    private let _passengerResourceRepository: any PassengerResourceRepositoryProtocol
    weak var passengerDataManagerDelegate: PassengerDataManagerDelegate?
    
    init(_cdPassengerDataRepository: any PassengerCoreDataRepositoryProtocol = PassengerCoreDataRepository(),
         _passengerResourceRepository: any PassengerResourceRepositoryProtocol = PassengerResourceRepository())
    {
        self._cdPassengerDataRepository = _cdPassengerDataRepository
        self._passengerResourceRepository = _passengerResourceRepository
    }

    func getPassengerRecord(completionHandler:@escaping(_ result: Array<Passenger>?)-> Void) {
        let response = _cdPassengerDataRepository.getAll()
        if(response.count != 0) {
            // return response to the view controller
            completionHandler(response)
        }
        else {
            completionHandler(nil)
        }
    }
    
    func getPassengerRecordForHost(completionHandler:@escaping(_ result: Array<Passenger>?)-> Void) {
        // get data from api
        _passengerResourceRepository.getRecordsFromAPI { [weak self] apiResponse in
            guard let self else { return }
            if(apiResponse != nil && apiResponse?.count != 0){
                // insert record in core data
                _ = _cdPassengerDataRepository.batchInsertPassengerRecords(records: apiResponse!)
                completionHandler(apiResponse)
            }
            else {
                // get data from file
                _passengerResourceRepository.getRecords { [weak self] apiResponse in
                    guard let self else { return }
                    if(apiResponse != nil && apiResponse?.count != 0){
                        // insert record in core data
                        _ = _cdPassengerDataRepository.batchInsertPassengerRecords(records: apiResponse!)
                        completionHandler(apiResponse)
                    }
                    else {
                        completionHandler(nil)
                    }
                }
            }
        }
    }
    
    func getPassengerRecordForPeer(completionHandler:@escaping(_ result: Array<Passenger>?)-> Void) {
        completionHandler(nil)
    }
    
    func getPassengersAt(indexPath: IndexPath) -> Passenger? {
        return _cdPassengerDataRepository.getPassengersAt(indexPath: indexPath)
    }
    
    func getPassengerAndMealAt(indexPath: IndexPath) -> (Passenger?, Meal?) {
        return _cdPassengerDataRepository.getPassengerAndMealAt(indexPath: indexPath)
    }
    
    func getPassengerCount() -> Int {
        return _cdPassengerDataRepository.getPassengerCount()
    }
    
    func deletePassenger(byIdentifier id: String) -> Bool
    {
        return _cdPassengerDataRepository.delete(byIdentifier: id)
    }

    func updatePassenger(record: Passenger) -> Bool
    {
        return _cdPassengerDataRepository.update(record: record)
    }
    
    func resetCoreData()
    {
        return _cdPassengerDataRepository.resetCoreData()
    }
}

extension PassengerDataManager : PassengerCoreDataRepositoryDelegate
{
    func passengerDataUpdated() {
        passengerDataManagerDelegate?.passengerDataUpdated()
    }
}
