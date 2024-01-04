//
//  MealTableViewCell.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblQuantityTitle: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var lblCostTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
