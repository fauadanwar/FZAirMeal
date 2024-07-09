//
//  Record.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

protocol Record: Hashable, Codable {
    var id: String { get }
    func data() -> Data?
}
