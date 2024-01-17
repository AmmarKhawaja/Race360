//
//  TableViewCell.swift
//  Race360
//
//  Created by Ammar Khawaja on 1/11/24.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var positionText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
