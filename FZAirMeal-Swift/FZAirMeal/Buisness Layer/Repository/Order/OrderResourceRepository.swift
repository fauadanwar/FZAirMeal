//
//  OrderResourceRepository.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 16/07/24.
//

import Foundation
protocol OrderResourceRepositoryProtocol {
    associatedtype T where T: Order
    func getOrderRecordsFromHost(host: PairingDevice, completionHandler: @escaping (Array<T>?) -> Void)
}

struct OrderResourceRepository : OrderResourceRepositoryProtocol {
    typealias T = Order
    private let peerConnectionRepository: PeerConnectionRepositoryProtocol = PeerConnectionRepository.shared

    static let shared = OrderResourceRepository()
    private init() {}
    
    func getOrderRecordsFromHost(host: PairingDevice, completionHandler: @escaping (Array<T>?) -> Void) {
        //use peer connection to get data from host
        peerConnectionRepository.sendResquestForOrders(toHost: host, completionHandler: completionHandler)
    }
}
