//
//  AlertCell.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-21.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class AlertCell: UITableViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet var tickerLabel: UILabel!
    @IBOutlet var crossesLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
