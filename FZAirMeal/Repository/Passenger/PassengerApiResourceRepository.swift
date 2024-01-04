//
//  PassengerApiResourceRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

struct PassengerApiResourceRepository : PassengerApiResourceRepositoryProtocol {

    func getPassengerRecordsFromAPI(completionHandler: @escaping (Array<Passenger>?) -> Void) {
        URLSession.shared.dataTask(with: ApiResource.passengerResource) { (data, response, error) in
            if(error == nil && data != nil) {
                do {
                    // deocding the response
                    let result = try JSONDecoder().decode(PassengersResponse.self, from: data!)
                    if(result.errorMessage?.isEmpty == true) {
                        completionHandler(result.passengers) // sending decoded response back
                    }else{
                        debugPrint("error in API response")
                        completionHandler(nil)
                    }

                } catch let error {
                    debugPrint(error)
                    completionHandler(nil)
                }
            }

        }.resume()
    }
    
    // Fetch data from local file (taking a JSON file for simplicity)
    func getPassengerRecords(completionHandler:@escaping(_ result: Array<Passenger>?)->Void) {
        guard let url = Bundle.main.url(forResource: "Passengers", withExtension: "json") else {
             debugPrint("Sample data file not found.")
             completionHandler(nil)
             return
         }

         do {
             let data = try Data(contentsOf: url)
             let decoder = JSONDecoder()
             let result = try decoder.decode(PassengersResponse.self, from: data)
             completionHandler(result.passengers) // sending decoded response back
         } catch {
             debugPrint("Error decoding sample data: \(error.localizedDescription)")
             completionHandler(nil)
         }
     }
}
