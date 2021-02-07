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
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var isEditingTransaction = false
    var transaction: Transaction?
    
    override func viewDidLoad() {
        addBuyTransactionView.alpha = 1
        addSellTransactionView.alpha = 0
        
        self.title = "Add Transaction"

        if (isEditingTransaction){
            self.title = "Edit Transaction"

            segmentedControl.isEnabled = false
            if (transaction?.getTransactionType() == Transaction.typeBought || transaction?.getTransactionType() == Transaction.typeReceived){
                addBuyTransactionView.alpha = 1
                addSellTransactionView.alpha = 0
                segmentedControl.selectedSegmentIndex = 0
            }else{
                addBuyTransactionView.alpha = 0
                addSellTransactionView.alpha = 1
                segmentedControl.selectedSegmentIndex = 1
            }
        }
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddBuyTransactionVC"{
            let dest = segue.destination as! AddBuyTransactionVC
            dest.coin = coin
            dest.coinHandler = coinHandler
            dest.isEditingTransaction = isEditingTransaction
            dest.transaction = isEditingTransaction ? transaction : nil
        }
        else if segue.identifier == "goToAddSellTransactionVC"{
            let dest = segue.destination as! AddSellTransactionVC
            dest.coin = coin
            dest.coinHandler = coinHandler
            dest.isEditingTransaction = isEditingTransaction
            dest.transaction = isEditingTransaction ? transaction : nil
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        switch sender.selectedSegmentIndex{
        case 0:
            addBuyTransactionView.alpha = 1
            addSellTransactionView.alpha = 0
        case 1:
            addBuyTransactionView.alpha = 0
            addSellTransactionView.alpha = 1
        default:
            addBuyTransactionView.alpha = 1
            addSellTransactionView.alpha = 0
        }
    }
}
