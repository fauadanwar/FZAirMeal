//
//  Date+toString.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 11/07/24.
//

import Foundation

extension Date {
    func toString(format: String = "yyyy-MM-dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
