//
//  MealApiResourceRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation
import CoreData

struct MealApiResourceRepository : MealApiResourceRepositoryProtocol {

    func getMealRecordsFromAPI(completionHandler: @escaping (Array<Meal>?) -> Void) {
        URLSession.shared.dataTask(with: ApiResource.mealResource) { (data, response, error) in
            if(error == nil && data != nil) {
                do {
                    // deocding the response
                    let result = try JSONDecoder().decode(MealResponse.self, from: data!)
                    if(result.errorMessage?.isEmpty == true) {
                        completionHandler(result.meals) // sending decoded response back
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
    func getMealRecords(completionHandler:@escaping(_ result: Array<Meal>?)->Void) {
        guard let url = Bundle.main.url(forResource: "Meals", withExtension: "json") else {
             debugPrint("Sample data file not found.")
             completionHandler(nil)
             return
         }

         do {
             let data = try Data(contentsOf: url)
             let decoder = JSONDecoder()
             let result = try decoder.decode(MealResponse.self, from: data)
             completionHandler(result.meals) // sending decoded response back
         } catch {
             debugPrint("Error decoding sample data: \(error.localizedDescription)")
             completionHandler(nil)
         }
     }
}
