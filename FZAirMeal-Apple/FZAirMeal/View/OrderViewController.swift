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

    private let refreshControl = UIRefreshControl()
    lazy var orderDataProvider: OrderProvider =
    {
        let dataProvider = OrderProvider(With: self)
        return dataProvider
    }()
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
        orderDataProvider.fetchedResultController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderTableViewCell

        let order = orderDataProvider.fetchedResultController.object(at: indexPath).convertToRecord()
        cell.lblTime.text = order?.time.toString()
        cell.lblMealName.text = order?.meal.name
        cell.lblPassengerSeatNumber.text = order?.passenger.seatNumber
        cell.lblTimeTitle.text = "Time:"

        return cell
    }
}

extension OrderViewController : NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tblOrderList.reloadData()
    }
}

extension Date {
    func toString(format: String = "yyyy-MM-dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
