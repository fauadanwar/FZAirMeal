//
//  PassengerTableViewCell.swift
//  FZAirMeal
//
//  Created by Fanwar on 04/01/24.
//

import UIKit

class PassengerTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSeatNumber: UILabel!
    @IBOutlet weak var lblMaelTitle: UILabel!
    @IBOutlet weak var lblMealName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func confiureCell(passenger: Passenger?, meal: Meal?)
    {
        lblMaelTitle.text = "Meal:"
        lblMealName.text = meal?.name ?? "No Order"
        lblName.text = passenger?.name
        lblSeatNumber.text = passenger?.seatNumber
    }
}
