//
//  ViewController.swift
//  FZAirMeal
//
//  Created by Fanwar on 03/01/24.
//

import UIKit
import CoreData

class PassengerViewController: UIViewController {

    @IBOutlet weak var tblPassengerList: UITableView!

    lazy var passengerDataProvider: PassengerProvider =
    {
        let dataProvider = PassengerProvider(With: self)
        return dataProvider
    }()
    private let passengerViewModel = PassengerViewModel()
    var pairingViewModel: PairingViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        PersistentStorage.shared.printDocumentDirectoryPath()
        self.tblPassengerList.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == SegueIdentifier.navigateToMealView)
        {
            let mealViewController = segue.destination as? MealViewController
            guard mealViewController != nil else { return }
            let passenger = passengerDataProvider.fetchedResultController.object(at: self.tblPassengerList.indexPathForSelectedRow!).convertToRecord()
            mealViewController?.pairingViewModel = pairingViewModel
            mealViewController?.selectedPassenger = passenger
        }
    }
}

extension PassengerViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        passengerDataProvider.fetchedResultController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PassengerCell") as! PassengerTableViewCell
        let cdPassenger = passengerDataProvider.fetchedResultController.object(at: indexPath)
        let passenger = cdPassenger.convertToRecord()
        let meal = cdPassenger.toOrder?.toMeal?.convertToRecord()
        cell.lblMaelTitle.text = "Meal:"
        cell.lblMealName.text = meal?.name ?? "No Order"
        cell.lblName.text = passenger?.name
        cell.lblSeatNumber.text = passenger?.seatNumber

        return cell
    }
}

extension PassengerViewController : NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tblPassengerList.reloadData()
    }
}
