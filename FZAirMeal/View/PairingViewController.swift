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
        
        pairingViewModel.$permissionRequest
            .receive(on: DispatchQueue.main)
            .sink { [weak self] permissionRequest in
                guard let self = self, let permissionRequest else { return }
                self.displayAlert(permissionRequest: permissionRequest)
            }
            .store(in: &subscriptions)
        
        pairingViewModel.$peers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peers in
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pairingViewModel.startBrowsing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pairingViewModel.finishBrowsing()
    }

    @IBAction func switchPairingValueChange(_ sender: UISwitch) {
        pairingViewModel.isAdvertised = sender.isOn
    }
    
    private func displayAlert(permissionRequest: PermitionRequest)
    {
        let alert = UIAlertController(title: "Do you want to join \(permissionRequest.peerId.displayName)", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { [weak self] (action) in
            permissionRequest.onRequest(true)
            guard let self = self else { return }
            self.pairingViewModel.show(peerId: permissionRequest.peerId)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            permissionRequest.onRequest(false)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
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
        pairingViewModel.peers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell") as! PairingTableViewCell

        cell.imageView?.image = UIImage(systemName: "iphone.gen1")
        cell.lblDeviceName.text = pairingViewModel.peers[indexPath.row].peerId.displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblPeersList.deselectRow(at: indexPath, animated: true)
        pairingViewModel.selectedPeer = pairingViewModel.peers[indexPath.row]
    }
}
