//
//  PassengerRepositoryProtocol.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
protocol PassengerRepositoryProtocol {
    func getPassengerRecords(completionHandler:@escaping(_ result: Array<Passenger>?)->Void)
}

protocol PassengerCoreDataRepositoryProtocol : PassengerRepositoryProtocol, BaseCoreDataRepository where T == Passenger{
    func insertPassengerRecords(records:Array<Passenger>) -> Bool
    func batchInsertPassengerRecords(records:Array<Passenger>) -> Bool
}

protocol PassengerApiResourceRepositoryProtocol : PassengerRepositoryProtocol {
    func getPassengerRecordsFromAPI(completionHandler: @escaping (Array<Passenger>?) -> Void)
}
