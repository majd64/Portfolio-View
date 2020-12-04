//
//  AddBuyTransactionVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-07.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class AddSellTransactionVC: UITableViewController, UITextFieldDelegate{
    var coin: Coin!
    var coinHandler: CoinHandler!
    var selectedFiat: String!
    var transactionType: String = Transaction.typeSold
    var isMissingRequiredField = false
    var isNegativeBalance = false
    
    @IBOutlet weak var pairCell: UITableViewCell!
    @IBOutlet weak var pairLabel: UILabel!
    @IBOutlet weak var amountReceivedCell: UITableViewCell!
    @IBOutlet weak var amountRecievedLabel: UILabel!
    @IBOutlet weak var amountSoldLabel: UILabel!
    @IBOutlet weak var selectedPairLabel: UILabel!
    @IBOutlet weak var amountSoldTextField: UITextField!{
        didSet { amountSoldTextField?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var amountRecievedTextField: UITextField!{
        didSet { amountRecievedTextField?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var notesTextField: UITextField!
    
    override func viewDidLoad() {
        amountSoldTextField.delegate = self
        amountRecievedTextField.delegate = self
        notesTextField.delegate = self
        selectedFiat = coinHandler.preferredCurrency
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadTableView()
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            transactionType = Transaction.typeSold
        }else{
            transactionType = Transaction.typeSent
        }
        reloadTableView()
    }
    
    private func reloadTableView(){
        selectedPairLabel.text = selectedFiat.uppercased()
        amountRecievedLabel.text = "Amount recieved (\(String(describing: selectedFiat.uppercased())))"
        if transactionType == Transaction.typeSold{
            amountSoldLabel.text = "Amount sold (\(coin.getSymbol().uppercased()))"
            pairCell.isUserInteractionEnabled = true
            pairLabel.isEnabled = true
            amountReceivedCell.isUserInteractionEnabled = true
            amountRecievedLabel.isEnabled = true
        }
        else if transactionType == Transaction.typeSent{
            amountSoldLabel.text = "Amount sent (\(coin.getSymbol().uppercased()))"
            pairCell.isUserInteractionEnabled = false
            pairLabel.isEnabled = false
            amountReceivedCell.isUserInteractionEnabled = false
            amountRecievedLabel.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 4{
            if let amountSold = Double(amountSoldTextField.text ?? ""){
                if coin.getBalance() - amountSold < 0{
                    isMissingRequiredField = false
                    isNegativeBalance = true
                    tableView.reloadData()
                    return
                }
                if transactionType == Transaction.typeSold{
                    if let amountRecieved = Double(amountRecievedTextField.text ?? ""){
                        let transaction = Transaction(amountOfParentCoinSold: amountSold, soldFor: selectedFiat, amountOfPairReceived: amountRecieved)
                        if let notes = notesTextField.text{
                            transaction.setNotes(notes: notes)
                        }
                        coin.addTransaction(transaction)
                        coinHandler.refresh()
                        _ = navigationController?.popViewController(animated: true)
                        return
                    }
                }
                else if transactionType == Transaction.typeSent{
                    let transaction = Transaction(amountSent: amountSold)
                    if let notes = notesTextField.text{
                        transaction.setNotes(notes: notes)
                    }
                    coin.addTransaction(transaction)
                    coinHandler.refresh()
                    _ = navigationController?.popViewController(animated: true)
                    return
                }
            }
            isMissingRequiredField = true
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 4{
            if isMissingRequiredField{
                return "Missing required fields"
            }
            else if isNegativeBalance{
                return "You cannot sell more than you have"
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
        amountSoldTextField.endEditing(true)
        amountRecievedTextField.endEditing(true)
        notesTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 2{
            return 2
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
