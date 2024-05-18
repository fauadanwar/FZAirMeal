//
//  Passenger.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

class Passenger: Record, Hashable, Codable {
    static func == (lhs: Passenger, rhs: Passenger) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let name: String
    let seatNumber: String
    let Order: Order?
    
    init(id: String, name: String, seatNumber: String, Order: Order?) {
        self.id = id
        self.name = name
        self.seatNumber = seatNumber
        self.Order = Order
    }
}

struct PassengersResponse: Decodable {
    let errorMessage: String?
    let passengers: [Passenger]?

    enum CodingKeys: String, CodingKey {
        case passengers
        case errorMessage
    }
}
