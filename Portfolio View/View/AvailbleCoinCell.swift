//
//  AvailbleCoinCell.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-12-16.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class AvailbleCoinCell: UITableViewCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var enabledSwitch: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
