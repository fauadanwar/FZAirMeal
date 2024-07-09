//
//  PassengerDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
struct PassengerDataManager {

    private let _cdPassengerDataRepository : any PassengerCoreDataRepositoryProtocol
    private let _passengerResourceRepository: any PassengerResourceRepositoryProtocol
    
    init(_cdPassengerDataRepository: any PassengerCoreDataRepositoryProtocol = PassengerCoreDataRepository(),
         _passengerResourceRepository: any PassengerResourceRepositoryProtocol = PassengerResourceRepository())
    {
        self._cdPassengerDataRepository = _cdPassengerDataRepository
        self._passengerResourceRepository = _passengerResourceRepository
    }

    func getPassengerRecordForHost(completionHandler:@escaping(_ result: Array<Passenger>?)-> Void) {
        let response = _cdPassengerDataRepository.getAll()
        if(response.count != 0) {
            // return response to the view controller
            completionHandler(response)
        }
        else {
            // get data from api
            _passengerResourceRepository.getRecordsFromAPI { apiResponse in
                if(apiResponse != nil && apiResponse?.count != 0){
                    // insert record in core data
                    _ = _cdPassengerDataRepository.batchInsertPassengerRecords(records: apiResponse!)
                    completionHandler(apiResponse)
                }
                else {
                    // get data from file
                    _passengerResourceRepository.getRecords { apiResponse in
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
    }
    
    func getPassengerRecordForPeer(completionHandler:@escaping(_ result: Array<Passenger>?)-> Void) {
        completionHandler(nil)
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
