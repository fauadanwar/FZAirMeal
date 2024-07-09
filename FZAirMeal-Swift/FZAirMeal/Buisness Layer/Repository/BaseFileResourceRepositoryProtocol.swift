//
//  BaseFileResourceRepositoryProtocol.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 01/07/24.
//

import Foundation

protocol BaseFileResourceRepositoryProtocol
{
    associatedtype T where T: Record
    var fileName: String { get }
    func getRecords(completionHandler:@escaping(_ result: Array<T>?)->Void)
}

extension BaseFileResourceRepositoryProtocol
{
    // Fetch data from local file (taking a JSON file for simplicity)
    func getRecords(completionHandler:@escaping(_ result: Array<T>?)->Void) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
             debugPrint("Sample data file not found.")
             completionHandler(nil)
             return
         }
         do {
             let data = try Data(contentsOf: url)
             let decoder = JSONDecoder()
             let result = try decoder.decode([T].self, from: data)
             completionHandler(result) // sending decoded response back
         } catch {
             debugPrint("Error decoding sample data: \(error.localizedDescription)")
             completionHandler(nil)
         }
     }
}
