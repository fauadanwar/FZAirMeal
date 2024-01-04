//
//  PairingViewController.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import UIKit

class PairingViewController: UIViewController {

    @IBOutlet weak var tblPeersList: UITableView!

    private let pairingViewModel = PairingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
}
