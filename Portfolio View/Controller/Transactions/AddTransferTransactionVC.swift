//
//  AddTransferTransactionVCTableViewController.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-09.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class AddTransferTransactionVC: UITableViewController, UITextFieldDelegate {
    var coin: Coin!
    var coinHandler: CoinHandler!
    var isMissingRequiredField = false
    var otherCoin: Coin!
    var isNegativeBalance = false
    
    @IBOutlet weak var exchangeFromSelectedLabel: UILabel!
    @IBOutlet weak var exchangeToSelectedLabel: UILabel!
    @IBOutlet weak var totalSentTextField: UITextField!
    @IBOutlet weak var totalRecievedTextField: UITextField!
    @IBOutlet weak var totalSentLabel: UILabel!
    @IBOutlet weak var totalRecievedLabel: UILabel!
    
    override func viewDidLoad() {
        totalSentTextField.delegate = self
        totalRecievedTextField.delegate = self
        if coinHandler.getCoins()[0].getSymbol() == coin.getSymbol(){
            otherCoin = coinHandler.getCoins()[1]
        }else{
            otherCoin = coinHandler.getCoins()[0]
        }
        updateLabelTexts()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLabelTexts()
    }
    
    private func updateLabelTexts(){
        exchangeFromSelectedLabel.text = coin.getSymbol()
        exchangeToSelectedLabel.text = otherCoin.getSymbol()
        
        totalSentLabel.text = "Total Sent (\(coin.getSymbol()))"
        totalRecievedLabel.text = "Total Recieved (\(otherCoin.getSymbol()))"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        totalSentTextField.endEditing(true)
        totalRecievedTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSelectPairVC"{
            let dest = segue.destination as! SelectPairVC
            dest.coin = coin
            dest.coinHandler = coinHandler
            dest.sender = self
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1{
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2{
            if isMissingRequiredField{
                return "Missing Required Fields"
            }
            else if isNegativeBalance{
                return "You cannot sell more than you have"
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2{
            if let amountSent = Double(totalSentTextField.text ?? ""), let amountRecieved = Double(totalRecievedTextField.text ?? ""){
                if coin.getBalance() - amountSent < 0{
                    isMissingRequiredField = false
                    isNegativeBalance = true
                    tableView.reloadData()
                    return
                }
                let sentTransaction = Transaction(amountOfParentCoinTransferred: amountSent, transferredTo: otherCoin.getID(), amountOfPairReceived: amountRecieved)
                coin.addTransaction(sentTransaction)
                
                let recievedTransaction = Transaction(amountOfParentCoinReceived: amountRecieved, transferredFrom: coin.getID(), amountOfPairCoinTransferred: amountSent)
                
                otherCoin.addTransaction(recievedTransaction)
                _ = navigationController?.popViewController(animated: true)
                return
            }
            isMissingRequiredField = true
            tableView.reloadData()
        }
    }
}
