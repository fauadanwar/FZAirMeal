//
//  BaseApiResourceRepositoryProtocol.swift
//  FZAirMeal
//
//  Created by Fouad Mohammed Rafique Anwar on 01/07/24.
//

import Foundation

protocol BaseApiResourceRepositoryProtocol
{
    associatedtype T where T: Record
    var resourceURL: URL { get }
    func getRecordsFromAPI(completionHandler: @escaping (Array<T>?) -> Void)
}
    
extension BaseApiResourceRepositoryProtocol
{
    func getRecordsFromAPI(completionHandler: @escaping (Array<T>?) -> Void) {
        URLSession.shared.dataTask(with: resourceURL) { (data, response, error) in
            if(error == nil && data != nil) {
                do {
                    // deocding the response
                    let result = try JSONDecoder().decode([T].self, from: data!)
                    completionHandler(result) // sending decoded response back
                } catch let error {
                    debugPrint(error)
                    completionHandler(nil)
                }
            }
            else {
                debugPrint("Error fetching data from API: \(error?.localizedDescription ?? "Unknown error")")
                completionHandler(nil)
            }
        }.resume()
    }
}
