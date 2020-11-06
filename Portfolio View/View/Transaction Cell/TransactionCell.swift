//
//  CoinCell.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-26.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
   
    @IBOutlet weak var transactionTypeSymbolImage: UIImageView!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var amountOfCoinLabel: UILabel!
    @IBOutlet weak var amountOfFiatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
