//
//  MealResourceRepository.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import Foundation

protocol MealResourceRepositoryProtocol : BaseApiResourceRepositoryProtocol, BaseFileResourceRepositoryProtocol where T == Meal {
}

struct MealResourceRepository : MealResourceRepositoryProtocol {
    var resourceURL: URL = ApiResource.mealResource
    var fileName: String = "Meals"
    typealias T = Meal
    
    static let shared = MealResourceRepository()
    private init() {}
}
