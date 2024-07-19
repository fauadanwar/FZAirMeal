//
//  OrderViewController.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import UIKit
import CoreData

class OrderViewController: UIViewController {

    @IBOutlet weak var tblOrderList: UITableView!
    @IBOutlet weak var barButtonCancelOrder: UIBarButtonItem!
    private var orderViewModel: OrderViewModelProtocol = OrderViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblOrderList.reloadData()
        orderViewModel.orderViewModelDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    func updateView() {
        self.tblOrderList.reloadData()
        barButtonCancelOrder.isEnabled = orderViewModel.getOrdersCount() > 0
    }
    
    @IBAction func barButtonCancelOrderTapped(_ sender: Any) {
        
        if let indexPath = self.tblOrderList.indexPathForSelectedRow,
           let order = orderViewModel.getOrderAt(indexPath: indexPath)
        {
            if(orderViewModel.cancelOrder(order: order))
            {
                displayAlert(message: "Order Canceled")
            }
            else
            {
                displayAlert(message: "Failed to Canceled order")
            }
        }
        else
        {
            displayAlert(message: "Select Order first")
        }
    }
    
    private func displayAlert(message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}

extension OrderViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("order count: \(orderViewModel.getOrdersCount())")
       return orderViewModel.getOrdersCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderTableViewCell
        let records = orderViewModel.getPassengerMealAndOrderAt(indexPath: indexPath)
        cell.confiureCell(order: records.2, passenger: records.0, meal: records.1)
        return cell
    }
}

extension OrderViewController : OrderViewModelDelegate
{
    func orderDataUpdated() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            updateView()
        }
    }
}
