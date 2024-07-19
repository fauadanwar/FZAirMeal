//
//  PassengerDataManager.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

protocol PassengerDataManagerProtocol {
    var passengerDataManagerDelegate: PassengerDataManagerDelegate? { get set }
    func getPassengerRecordForHost(completionHandler:@escaping(_ result: Array<Passenger>?)-> Void)
    func getPassengerRecordForPeer(host: PairingDevice, completionHandler:@escaping(_ result: Array<Passenger>?)-> Void)
    func getPassengerRecord() -> Array<Passenger>?
    func getPassengerAt(indexPath: IndexPath) -> Passenger?
    func getPassengerWith(passengerId: String) -> Passenger?
    func getPassengerAndMealAt(indexPath: IndexPath) -> (Passenger?, Meal?)
    func getPassengerCount() -> Int
    func deletePassenger(byIdentifier id: String) -> Bool
    func updatePassenger(record: Passenger) -> Bool
    func resetCoreData()
}

protocol PassengerDataManagerDelegate: AnyObject
{
    func passengerDataUpdated()
}

class PassengerDataManager: PassengerDataManagerProtocol {

    private var _cdPassengerDataRepository : any PassengerCoreDataRepositoryProtocol
    private let _passengerResourceRepository: any PassengerResourceRepositoryProtocol
    
    weak var passengerDataManagerDelegate: PassengerDataManagerDelegate?
    
    init(_cdPassengerDataRepository: any PassengerCoreDataRepositoryProtocol = PassengerCoreDataRepository.shared,
         _passengerResourceRepository: any PassengerResourceRepositoryProtocol = PassengerResourceRepository.shared)
    {
        self._cdPassengerDataRepository = _cdPassengerDataRepository
        self._passengerResourceRepository = _passengerResourceRepository
        self._cdPassengerDataRepository.passengerCoreDataRepositoryDelegate = self
    }

    func getPassengerRecord() -> Array<Passenger>? {
        let response = _cdPassengerDataRepository.getAll()
        if(response.count != 0) {
            return response
        }
        else {
            return nil
        }
    }
    
    func getPassengerRecordForHost(completionHandler:@escaping(_ result: Array<Passenger>?)-> Void) {
        // get data from api
        _passengerResourceRepository.getRecordsFromAPI { [weak self] apiResponse in
            guard let self else { return }
            if let apiResponse,
               apiResponse.count > 0
            {
                // insert record in core data
                _ = _cdPassengerDataRepository.batchInsertPassengerRecords(records: apiResponse)
                completionHandler(apiResponse)
            }
            else {
                // get data from file
                _passengerResourceRepository.getRecords { [weak self] fileResponse in
                    guard let self else { return }
                    if let fileResponse,
                       fileResponse.count > 0
                    {
                        // insert record in core data
                        _ = _cdPassengerDataRepository.batchInsertPassengerRecords(records: fileResponse)
                        completionHandler(fileResponse)
                    }
                    else {
                        completionHandler(nil)
                    }
                }
            }
        }
    }
    
    func getPassengerRecordForPeer(host: PairingDevice, completionHandler:@escaping(_ result: Array<Passenger>?) -> Void) {
        _passengerResourceRepository.getPassengerRecordsFromHost(host: host) { [weak self] passengers in
            guard let passengers = passengers,
                  let self,
                  passengers.count > 0 else {
                completionHandler(nil)
                return
            }
            // insert record in core data
            _ = _cdPassengerDataRepository.batchInsertPassengerRecords(records: passengers)
            completionHandler(passengers)
        }
    }
    
    func getPassengerAt(indexPath: IndexPath) -> Passenger? {
        return _cdPassengerDataRepository.getPassengersAt(indexPath: indexPath)
    }   
    
    func getPassengerWith(passengerId: String) -> Passenger? {
        return _cdPassengerDataRepository.get(byIdentifier: passengerId)
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
