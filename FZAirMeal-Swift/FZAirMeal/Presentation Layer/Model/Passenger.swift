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
    let orderId: String?
    
    init(id: String, name: String, seatNumber: String, orderId: String?) {
        self.id = id
        self.name = name
        self.seatNumber = seatNumber
        self.orderId = orderId
    }
    
    func data() -> Data? {
      let encoder = JSONEncoder()
      return try? encoder.encode(self)
    }
}
