//
//  OrderTableViewCell.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMealName: UILabel!
    @IBOutlet weak var lblPassengerSeatNumber: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTimeTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
