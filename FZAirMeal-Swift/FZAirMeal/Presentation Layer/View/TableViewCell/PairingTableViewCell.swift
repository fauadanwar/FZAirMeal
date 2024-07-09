//
//  PairingTableViewCell.swift
//  FZAirMeal
//
//  Created by Fanwar on 05/01/24.
//

import UIKit
import Combine

class PairingTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var imageDevice: UIImageView!
    @IBOutlet weak var imageConnectionStatus: UIImageView!

    var subscriptions = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(pairingDevice: PairingDevice) {
        imageDevice.image = UIImage(systemName: "iphone.gen1")
        lblDeviceName.text = pairingDevice.id.displayName
        pairingDevice.$connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connectionStatus in
                guard let self else { return }
                switch connectionStatus {
                case .notConnected:
                    imageConnectionStatus.image = UIImage(systemName: "circle.dotted.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
                case .connecting:
                    imageConnectionStatus.image = UIImage(systemName: "app.connected.to.app.below.fill")
                case .connected:
                    imageConnectionStatus.image = UIImage(systemName: "circle.dotted.circle.fill")?.withTintColor(.green, renderingMode: .alwaysOriginal)
                @unknown default:
                    imageConnectionStatus.image = UIImage(systemName: "exclamationmark.transmission")
                }
            }
            .store(in: &subscriptions)
        
    }

}
