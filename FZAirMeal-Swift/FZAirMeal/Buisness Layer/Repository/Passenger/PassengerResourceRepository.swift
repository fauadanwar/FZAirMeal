//
//  PassengerResourceRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

protocol PassengerResourceRepositoryProtocol : BaseApiResourceRepositoryProtocol, BaseFileResourceRepositoryProtocol where T == Passenger {
    func getPassengerRecordsFromHost(host: PairingDevice, completionHandler: @escaping (Array<T>?) -> Void)
}

struct PassengerResourceRepository : PassengerResourceRepositoryProtocol {
    var resourceURL: URL = ApiResource.passengerResource
    var fileName: String = "Passengers"
    typealias T = Passenger
    private let peerConnectionRepository: PeerConnectionRepositoryProtocol = PeerConnectionRepository.shared

    static let shared = PassengerResourceRepository()
    private init() {}
    
    func getPassengerRecordsFromHost(host: PairingDevice, completionHandler: @escaping (Array<T>?) -> Void) {
        //use peer connection to get data from host
        peerConnectionRepository.sendResquestForPassengers(toHost: host, completionHandler: completionHandler)
    }
}
