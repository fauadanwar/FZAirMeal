//
//  CDRecord.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

protocol CDRecord
{
    associatedtype T
    func convertToRecord() -> T?
}
