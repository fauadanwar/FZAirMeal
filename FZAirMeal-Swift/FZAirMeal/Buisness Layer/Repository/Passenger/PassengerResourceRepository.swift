//
//  PassengerResourceRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

protocol PassengerResourceRepositoryProtocol : BaseApiResourceRepositoryProtocol, BaseFileResourceRepositoryProtocol where T == Passenger {
}

struct PassengerResourceRepository : PassengerResourceRepositoryProtocol {
    var resourceURL: URL = ApiResource.passengerResource
    var fileName: String = "Passengers"
    typealias T = Passenger
    
    static let shared = PassengerResourceRepository()
    private init() {}
}
