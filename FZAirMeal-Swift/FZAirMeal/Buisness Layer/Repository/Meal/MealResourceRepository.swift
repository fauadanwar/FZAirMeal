//
//  MealResourceRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

protocol MealResourceRepositoryProtocol : BaseApiResourceRepositoryProtocol, BaseFileResourceRepositoryProtocol where T == Meal {
    func getMealRecordsFromHost(host: PairingDevice, completionHandler: @escaping (Array<T>?) -> Void)
}

struct MealResourceRepository : MealResourceRepositoryProtocol {
    var resourceURL: URL = ApiResource.mealResource
    var fileName: String = "Meals"
    typealias T = Meal
    private let peerConnectionRepository: PeerConnectionRepository = PeerConnectionRepository.shared

    static let shared = MealResourceRepository()
    private init() {}
    func getMealRecordsFromHost(host: PairingDevice, completionHandler: @escaping (Array<T>?) -> Void) {
        //use peer connection to get data from host
        peerConnectionRepository.sendResquestForMeals(toHost: host, completionHandler: completionHandler)
    }
}
