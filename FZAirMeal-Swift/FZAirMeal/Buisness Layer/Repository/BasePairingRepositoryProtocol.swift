//
//  BasePairingRepositoryProtocol.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 07/07/24.
//

import Foundation
import MultipeerConnectivity

protocol BasePairingRepositoryProtocol {
    var session: MCSession { get }
    func resetAllCoreData()
}

extension BasePairingRepositoryProtocol {
    func resetAllCoreData() {
        PersistentStorage.shared.resetAllCoreData()
    }
}
