//
//  SendDataType.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation

enum SendDataType: String, Codable {
    case orders
    case passengers
    case meals
    case order
    case deleteOrder
}

struct DataWrapper: Codable {
    let type: SendDataType
    let data: Data?
}

extension DataWrapper {
    init<T: Record>(type: SendDataType, object: T) throws {
        self.type = type
        self.data = try JSONEncoder().encode(object)
    }
    
    init<T: Record>(type: SendDataType, objects: [T]) throws {
        self.type = type
        self.data = try JSONEncoder().encode(objects)
    }
    
    init(type: SendDataType) {
        self.type = type
        self.data = nil
    }
}
