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

    lazy var mealDataProvider: MealProvider =
    {
        let dataProvider = MealProvider(With: self)
        return dataProvider
    }()
    var selectedPassenger: Passenger? = nil
    private let mealViewModel = MealViewModel()
    var pairingViewModel: PairingViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblMealList.reloadData()
        if let _ = selectedPassenger?.orderId
        {
            barButtonPlaceOrder.isEnabled = false
        }
    }
    
    @IBAction func placeOrderButtonTapped(_ sender: Any) {
        
        if let selectedRow = self.tblMealList.indexPathForSelectedRow,
           let meal = mealDataProvider.fetchedResultController.object(at: selectedRow).convertToRecord(),
           let selectedPassenger
        {
            let order = Order(id: "\(UUID())", passengerId: selectedPassenger.id, mealId: meal.id, time: Date())
            if(mealViewModel.placeOrder(order: order))
            {
//                _ = pairingViewModel?.send(order: order) // User this response for ofline sync
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
            if message == "Order Placed"
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
        mealDataProvider.fetchedResultController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell") as! MealTableViewCell

        let meal = mealDataProvider.fetchedResultController.object(at: indexPath).convertToRecord()
        cell.lblName.text = meal?.name
        cell.lblQuantityTitle.text = "Meals Left:"
        if let quantity = meal?.quantity
        {
            cell.lblQuantity.text = quantity > 0 ? "\(quantity)" : "Out of Stock"
        }
        if let cost = meal?.cost
        {
            cell.lblCost.text = "\(cost)"
        }
        cell.lblDetails.text = meal?.details
        cell.lblCostTitle.text = "Cost:"

        return cell
    }
}

extension MealViewController : NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tblMealList.reloadData()
    }
}
