//
//  PassengerDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
struct PassengerDataManager {

    private let _cdPassengerDataRepository : any PassengerCoreDataRepositoryProtocol = PassengerCoreDataRepository()
    private let _passengerApiRepository: PassengerApiResourceRepositoryProtocol = PassengerApiResourceRepository()

    func getPassengerRecord(completionHandler:@escaping(_ result: Array<Passenger>?)-> Void) {

        _cdPassengerDataRepository.getPassengerRecords { response in
            if(response != nil && response?.count != 0){
                // return response to the view controller
                completionHandler(response)

            }else {
                // call the api
                _passengerApiRepository.getPassengerRecords { apiResponse in
                    if(apiResponse != nil && apiResponse?.count != 0){

                        // insert record in core data
                      _ = _cdPassengerDataRepository.batchInsertPassengerRecords(records: apiResponse!)
                        completionHandler(apiResponse)
                    }
                }
            }
        }

    }
    
    func deletePassenger(byIdentifier id: String) -> Bool
    {
        return _cdPassengerDataRepository.delete(byIdentifier: id)
    }

    func updatePassenger(record: Passenger) -> Bool
    {
        return _cdPassengerDataRepository.update(record: record)
    }
}
