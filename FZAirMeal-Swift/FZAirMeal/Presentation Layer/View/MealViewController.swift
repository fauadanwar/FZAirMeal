//
//  MealViewController.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import UIKit
import CoreData

class MealViewController: UIViewController {

    @IBOutlet weak var tblMealList: UITableView!
    @IBOutlet weak var barButtonPlaceOrder: UIBarButtonItem!

    var passenger: Passenger? = nil
    private var mealViewModel: MealViewModelProtocol = MealViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealViewModel.mealViewModelDelegate = self
    }
    
    func updateView() {
        self.tblMealList.reloadData()
        guard let passenger = self.passenger else { return }
        self.passenger = mealViewModel.getPassengerWith(passengerID: passenger.id)
        if let _ = passenger.orderId
        {
            barButtonPlaceOrder.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    @IBAction func placeOrderButtonTapped(_ sender: Any) {
        
        if let indexPath = self.tblMealList.indexPathForSelectedRow,
           let meal = mealViewModel.getMealAt(indexPath: indexPath),
           let passenger
        {
            let order = Order(id: "\(UUID())", passengerId: passenger.id, mealId: meal.id, time: Date())
            if(mealViewModel.sendOrder(order: order))
            {
                displayAlert(message: "Order Placed")
            }
            else
            {
                displayAlert(message: "Failed to place order")
            }
        }
        else
        {
            displayAlert(message: "Select meal first")
        }
    }
    
    private func displayAlert(message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            if message == "Order Placed" || message == "Order Canceled"
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}

extension MealViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("meal count: \( mealViewModel.getMealsCount())")
        return mealViewModel.getMealsCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell") as! MealTableViewCell
        let meal = mealViewModel.getMealAt(indexPath: indexPath)
        cell.confiureCell(meal: meal)
        return cell
    }
}

extension MealViewController : MealViewModelDelegate
{
    func mealDataUpdated() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            updateView()
        }
    }
}
