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
    private let mealViewModel = MealViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblMealList.reloadData()
        mealViewModel.mealViewModelDelegate = self
        if let _ = passenger?.orderId
        {
            barButtonPlaceOrder.title = "Place Order"
        }
        else {
            barButtonPlaceOrder.title = "Cancel Order"
        }
    }
    
    @IBAction func placeOrderButtonTapped(_ sender: Any) {
        
        if let indexPath = self.tblMealList.indexPathForSelectedRow,
           let meal = mealViewModel.getMealAt(indexPath: indexPath),
           let passenger
        {
            if let orderId = passenger.orderId
            {
                if(mealViewModel.cancelOrder(orderId: orderId))
                {
                    displayAlert(message: "Order Canceled")
                }
                else
                {
                    displayAlert(message: "Failed to Canceled order")
                }
            }
            else {
                let order = Order(id: "\(UUID())", passengerId: passenger.id, mealId: meal.id, time: Date())
                if(mealViewModel.placeOrder(order: order))
                {
                    displayAlert(message: "Order Placed")
                }
                else
                {
                    displayAlert(message: "Failed to place order")
                }
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
        mealViewModel.getMealsCount()
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
        self.tblMealList.reloadData()
    }
}
