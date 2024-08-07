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
    @IBOutlet weak var clearAllDataButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var buttonsParentStackView: UIStackView!
    @IBOutlet weak var tableViewLabel: UILabel!

    private let pairingViewModel: PairingViewModelProtocol = PairingViewModel()
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConnectivityData.shared.$pairingRole
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pairingRole in
                guard let self = self else { return }
                switch pairingRole {
                case .host:
                    self.title = "Host"
                    tableViewLabel.text = "Peers"
                    buttonsParentStackView.isHidden = false
                    syncOrderButton.isHidden = true
                case .peer:
                    self.title = "Peer"
                    tableViewLabel.text = "Hosts"
                    buttonsParentStackView.isHidden = false
                    syncOrderButton.isHidden = false
                case .unknown:
                    self.title = "Unknown"
                    buttonsParentStackView.isHidden = true
                }
            }
            .store(in: &subscriptions)
        
        ConnectivityData.shared.$isServiceStarted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isServiceStarted in
                guard let self = self else { return }
                buttonStackView.isHidden = !isServiceStarted
                switchPairing.isOn = isServiceStarted
            }
            .store(in: &subscriptions)
        
        ConnectivityData.shared.$requestingPairingDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] requetingPairingDevice in
                guard let self = self, let requetingPairingDevice else { return }
                self.displayAlert(requetingPairingDevice: requetingPairingDevice)
            }
            .store(in: &subscriptions)
        
        ConnectivityData.shared.$availabelHosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] availabelHosts in
                guard let self = self else { return }
                self.tblPeersList.reloadData()
            }
            .store(in: &subscriptions)
        
        ConnectivityData.shared.$joinedPeer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peer in
                guard let self = self else { return }
                self.tblPeersList.reloadData()
            }
            .store(in: &subscriptions)
    }

    @IBAction func switchPairingValueChange(_ sender: UISwitch) {
        ConnectivityData.shared.isServiceStarted = sender.isOn
    }
    
    @IBAction func activityButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Pairing Options", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Become Host", style: .default, handler: { _ in
            ConnectivityData.shared.pairingRole = .host
        }))
        alert.addAction(UIAlertAction(title: "Become Peer", style: .default, handler: { _ in
            ConnectivityData.shared.pairingRole = .peer
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            if let presenter = alert.popoverPresentationController {
                presenter.barButtonItem = activityButton
            }
        }
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
       @IBAction func clearAllDataTapped(_ sender: UIButton) {
           pairingViewModel.clearAllData()
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
        switch ConnectivityData.shared.pairingRole {
        case .host:
            ConnectivityData.shared.joinedPeer.count
        case .peer:
            ConnectivityData.shared.availabelHosts.count
        case .unknown:
            0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell") as! PairingTableViewCell
        switch ConnectivityData.shared.pairingRole {
        case .host:
            let peer = ConnectivityData.shared.joinedPeer[indexPath.row]
            cell.configureCell(pairingDevice: peer)
        case .peer:
            let host = ConnectivityData.shared.availabelHosts[indexPath.row]
            cell.configureCell(pairingDevice: host)
        case .unknown:
            cell.lblDeviceName.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblPeersList.deselectRow(at: indexPath, animated: true)
        if ConnectivityData.shared.pairingRole == .peer {
            ConnectivityData.shared.selectedHost = ConnectivityData.shared.availabelHosts[indexPath.row]
        }
    }
}
