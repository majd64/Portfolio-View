//
//  AddBuyTransactionVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-07.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class AddBuyTransactionVC: UITableViewController, UITextFieldDelegate{
    var coin: Coin!
    var coinHandler: CoinHandler!
    var selectedFiat: ExchangeRate!
    var transactionType: String = Transaction.typeBought
    var isMissingRequiredFieldsTextVisible = false
    
    @IBOutlet weak var pairCell: UITableViewCell!
    @IBOutlet weak var pairLabel: UILabel!
    @IBOutlet weak var amountSpentCell: UITableViewCell!
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var amountBoughtLabel: UILabel!
    @IBOutlet weak var selectedPairLabel: UILabel!
    @IBOutlet weak var amountBoughtTextField: UITextField!
    @IBOutlet weak var amountSpentTextField: UITextField!
    
    override func viewDidLoad() {
        amountBoughtTextField.delegate = self
        amountSpentTextField.delegate = self
        selectedFiat = coinHandler.getPreferredExchangeRate()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadTableView()
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            transactionType = Transaction.typeBought
        }else{
            transactionType = Transaction.typeReceived
        }
        reloadTableView()
    }
    
    private func reloadTableView(){
        selectedPairLabel.text = selectedFiat.getSymbol()
        amountSpentLabel.text = "Amount Spent (\(selectedFiat.getSymbol()))"
        if transactionType == Transaction.typeBought{
            amountBoughtLabel.text = "Amount Bought (\(coin.getSymbol()))"
            pairCell.isUserInteractionEnabled = true
            pairLabel.isEnabled = true
            amountSpentCell.isUserInteractionEnabled = true
            amountSpentLabel.isEnabled = true
        }
        else if transactionType ==  Transaction.typeReceived{
            amountBoughtLabel.text = "Amount Recieved (\(coin.getSymbol()))"
            pairCell.isUserInteractionEnabled = false
            pairLabel.isEnabled = false
            amountSpentCell.isUserInteractionEnabled = false
            amountSpentLabel.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3{
            if let amountBought = Double(amountBoughtTextField.text ?? ""){
                if transactionType == Transaction.typeBought{
                    if let amountSpent = Double(amountSpentTextField.text ?? ""){
                        let transaction = Transaction(amountOfParentCoinBought: amountBought, boughtWith: selectedFiat.getId(), amountOfPairSpent: amountSpent)
                        coin.addTransaction(transaction)
                        _ = navigationController?.popViewController(animated: true)
                        return
                    }
                }
                else if transactionType == Transaction.typeReceived{
                    let transaction = Transaction(amountReceived: amountBought)
                    coin.addTransaction(transaction)
                    _ = navigationController?.popViewController(animated: true)
                    return
                }
            }
            isMissingRequiredFieldsTextVisible = true
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 3{
            if isMissingRequiredFieldsTextVisible{
                return "Missing Required Fields"
            }
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSelectPairVC"{
            let dest = segue.destination as! SelectPairVC
            dest.coin = coin
            dest.coinHandler = coinHandler
            dest.sender = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        amountBoughtTextField.endEditing(true)
        amountSpentTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 2{
            return 2
        }else{
            return 1
        }
    }
}
