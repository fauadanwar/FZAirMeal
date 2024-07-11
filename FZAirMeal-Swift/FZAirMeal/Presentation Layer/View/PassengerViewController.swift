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

    private let passengerViewModel = PassengerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tblPassengerList.reloadData()
        passengerViewModel.passengerViewModelDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tblPassengerList.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == SegueIdentifier.navigateToMealView)
        {
            if let mealViewController = segue.destination as? MealViewController,
               let indexPath = self.tblPassengerList.indexPathForSelectedRow {
                let passenger = passengerViewModel.getPassengersAt(indexPath: indexPath)
                mealViewController.passenger = passenger
            }
        }
    }
}

extension PassengerViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Passenger count: \(passengerViewModel.getPassengerCount())")
        return passengerViewModel.getPassengerCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PassengerCell") as! PassengerTableViewCell
        let passengerAndMeal = passengerViewModel.getPassengerAndMealAt(indexPath: indexPath)
        cell.confiureCell(passenger: passengerAndMeal.0, meal: passengerAndMeal.1)
        return cell
    }
}

extension PassengerViewController : PassengerViewModelDelegate
{
    func passengerDataUpdated() {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            tblPassengerList.reloadData()
        }
    }
}
