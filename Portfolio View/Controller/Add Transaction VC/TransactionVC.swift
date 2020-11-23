//
//  TransactionParentVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-07.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class TransactionVC: UIViewController {
    var coinHandler: CoinHandler!
    var coin: Coin!
    
    @IBOutlet weak var addBuyTransactionView: UIView!
    @IBOutlet weak var addSellTransactionView: UIView!
    @IBOutlet weak var addTransferTransactionView: UIView!
    
    override func viewDidLoad() {
        addBuyTransactionView.alpha = 1
        addSellTransactionView.alpha = 0
        addTransferTransactionView.alpha = 0
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddBuyTransactionVC"{
            let dest = segue.destination as! AddBuyTransactionVC
            dest.coin = coin
            dest.coinHandler = coinHandler
        }
        else if segue.identifier == "goToAddSellTransactionVC"{
            let dest = segue.destination as! AddSellTransactionVC
            dest.coin = coin
            dest.coinHandler = coinHandler
        }
        else if segue.identifier == "goToAddTransferTransactionVC"{
            let dest = segue.destination as! AddTransferTransactionVC
            dest.coin = coin
            dest.coinHandler = coinHandler
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        switch sender.selectedSegmentIndex{
        case 0:
            addBuyTransactionView.alpha = 1
            addSellTransactionView.alpha = 0
            addTransferTransactionView.alpha = 0
        case 1:
            addBuyTransactionView.alpha = 0
            addSellTransactionView.alpha = 1
            addTransferTransactionView.alpha = 0
        default:
            addBuyTransactionView.alpha = 0
            addSellTransactionView.alpha = 0
            addTransferTransactionView.alpha = 1
        }
    }
}
