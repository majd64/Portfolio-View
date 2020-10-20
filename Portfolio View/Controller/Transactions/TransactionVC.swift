//
//  TransactionParentVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-07.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class TransactionVC: UIViewController {
    
    @IBOutlet weak var addBuyTransactionView: UIView!
    @IBOutlet weak var addSellTransactionView: UIView!
    @IBOutlet weak var addTransferTransactionView: UIView!
    
    var coin: Coin!
    var coinHandler: CoinHandler!
    
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
        if sender.selectedSegmentIndex == 0{
            addBuyTransactionView.alpha = 1
            addSellTransactionView.alpha = 0
            addTransferTransactionView.alpha = 0
        }
        else if sender.selectedSegmentIndex == 1{
            addBuyTransactionView.alpha = 0
            addSellTransactionView.alpha = 1
            addTransferTransactionView.alpha = 0
        }
        else{
            addBuyTransactionView.alpha = 0
            addSellTransactionView.alpha = 0
            addTransferTransactionView.alpha = 1
        }
    }
    
}
