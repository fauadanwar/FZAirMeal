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


    private let orderViewModel = OrderViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tblOrderList.reloadData()
    }
}

extension OrderViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orderViewModel.getOrdersCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderTableViewCell
        let records = orderViewModel.getPassengerMealAndOrderAt(indexPath: indexPath)
        cell.confiureCell(order: records.2, passenger: records.0, meal: records.1)
        return cell
    }
}

extension OrderViewController : OrderDataManagerDelegate
{
    func orderDataUpdated() {
        self.tblOrderList.reloadData()
    }
}
