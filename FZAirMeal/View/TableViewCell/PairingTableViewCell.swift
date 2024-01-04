//
//  PairingTableViewCell.swift
//  FZAirMeal
//
//  Created by Fanwar on 05/01/24.
//

import UIKit

class PairingTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var imageDevice: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
