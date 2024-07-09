//
//  PairingViewController.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import UIKit
import Combine

class PairingViewController: UIViewController {

    @IBOutlet weak var tblPeersList: UITableView!
    @IBOutlet weak var switchPairing: UISwitch!
    @IBOutlet weak var activityButton: UIBarButtonItem!
    @IBOutlet weak var syncMealButton: UIButton!
    @IBOutlet weak var syncPassengerButton: UIButton!
    @IBOutlet weak var syncOrderButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var buttonsParentStackView: UIStackView!
    @IBOutlet weak var tableViewLabel: UILabel!

    private let pairingViewModel = PairingViewModel()
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        //This is bad approch doing this to save time
        if let passengerViewNavigationController = self.tabBarController?.viewControllers?[1] as? UINavigationController,
           let passengerViewController = passengerViewNavigationController.topViewController as? PassengerViewController
        {
            passengerViewController.pairingViewModel = pairingViewModel
        }
        
        pairingViewModel.$pairingRole
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pairingRole in
                guard let self = self else { return }
                switch pairingRole {
                case .host:
                    self.title = "Host"
                    tableViewLabel.text = "Peers"
                    buttonsParentStackView.isHidden = false
                case .peer:
                    self.title = "Peer"
                    tableViewLabel.text = "Hosts"
                    buttonsParentStackView.isHidden = false
                case .unknown:
                    self.title = "Unknown"
                    buttonsParentStackView.isHidden = true
                }
            }
            .store(in: &subscriptions)
        
        pairingViewModel.$isServiceStarted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isServiceStarted in
                guard let self = self else { return }
                buttonStackView.isHidden = !isServiceStarted
                switchPairing.isOn = isServiceStarted
            }
            .store(in: &subscriptions)
        
        pairingViewModel.$requetingPairingDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] requetingPairingDevice in
                guard let self = self, let requetingPairingDevice else { return }
                self.displayAlert(requetingPairingDevice: requetingPairingDevice)
            }
            .store(in: &subscriptions)
        
        pairingViewModel.$availabelHosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] availabelHosts in
                guard let self = self else { return }
                self.tblPeersList.reloadData()
            }
            .store(in: &subscriptions)
        
        pairingViewModel.$joinedPeer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peer in
                guard let self = self else { return }
                self.tblPeersList.reloadData()
            }
            .store(in: &subscriptions)
    }

    @IBAction func switchPairingValueChange(_ sender: UISwitch) {
        pairingViewModel.isServiceStarted = sender.isOn
    }
    
    @IBAction func activityButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Pairing Options", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Become Host", style: .default, handler: { _ in
            self.pairingViewModel.pairingRole = .host
        }))
        alert.addAction(UIAlertAction(title: "Become Peer", style: .default, handler: { _ in
            self.pairingViewModel.pairingRole = .peer
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func displayAlert(requetingPairingDevice: PairingDevice)
    {
        let alert = UIAlertController(title: "Do you want to join \(requetingPairingDevice.id.displayName)", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.pairingViewModel.grantPermisson(requetingPairingDevice: requetingPairingDevice, permission: true)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { [weak self] (action) in
            guard let self = self else { return }
            self.pairingViewModel.grantPermisson(requetingPairingDevice: requetingPairingDevice, permission: false)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    // Fetch data actions
       @IBAction func fetchOrdersTapped(_ sender: UIButton) {
           pairingViewModel.fetchData(ofType: .orders)
       }

       @IBAction func fetchPassengersTapped(_ sender: UIButton) {
           pairingViewModel.fetchData(ofType: .passengers)
       }

       @IBAction func fetchMealsTapped(_ sender: UIButton) {
           pairingViewModel.fetchData(ofType: .meals)
       }

       // Clear data actions
       @IBAction func clearOrdersTapped(_ sender: UIButton) {
           pairingViewModel.clearData(ofType: .orders)
       }

       @IBAction func clearPassengersTapped(_ sender: UIButton) {
           pairingViewModel.clearData(ofType: .passengers)
       }

       @IBAction func clearMealsTapped(_ sender: UIButton) {
           pairingViewModel.clearData(ofType: .meals)
       }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PairingViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch pairingViewModel.pairingRole {
        case .host:
            pairingViewModel.joinedPeer.count
        case .peer:
            pairingViewModel.availabelHosts.count
        case .unknown:
            0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell") as! PairingTableViewCell
        switch pairingViewModel.pairingRole {
        case .host:
            let peer = pairingViewModel.joinedPeer[indexPath.row]
            cell.configureCell(pairingDevice: peer)
        case .peer:
            let host = pairingViewModel.availabelHosts[indexPath.row]
            cell.configureCell(pairingDevice: host)
        case .unknown:
            cell.lblDeviceName.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblPeersList.deselectRow(at: indexPath, animated: true)
        if pairingViewModel.pairingRole == .peer {
            pairingViewModel.selectedHost = pairingViewModel.availabelHosts[indexPath.row]
        }
    }
}
