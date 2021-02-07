//
//  AddBuyTransactionVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-07.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class AddBuyTransactionVC: UITableViewController, UITextFieldDelegate{
    var coinHandler: CoinHandler!
    var coin: Coin!
    var selectedFiat: String!
    var transactionType: String = Transaction.typeBought
    var isMissingRequiredFieldsTextVisible = false
    
    var isEditingTransaction = false
    var transaction: Transaction?
    
    @IBOutlet weak var addOrSaveLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pairCell: UITableViewCell!
    @IBOutlet weak var pairLabel: UILabel!
    @IBOutlet weak var amountSpentCell: UITableViewCell!
    @IBOutlet weak var amountSpentLabel: UILabel!
    @IBOutlet weak var amountBoughtLabel: UILabel!
    @IBOutlet weak var selectedPairLabel: UILabel!
    @IBOutlet weak var amountBoughtTextField: UITextField!{
        didSet { amountBoughtTextField?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var amountSpentTextField: UITextField!{
        didSet { amountSpentTextField?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var notesTextField: UITextField!
    
    override func viewDidLoad() {
        amountBoughtTextField.delegate = self
        amountSpentTextField.delegate = self
        notesTextField.delegate = self
        selectedFiat = coinHandler.preferredCurrency
        addOrSaveLabel.text = "Add"
        if (isEditingTransaction){
            addOrSaveLabel.text = "Save"
            segmentedControl.isEnabled = false
            if (transaction?.getTransactionType() == Transaction.typeBought){
                transactionType = Transaction.typeBought
                segmentedControl.selectedSegmentIndex = 0
                selectedFiat = transaction!.getPairId()
                amountBoughtTextField.text = String(transaction!.getAmountOfParentCoin() as Double)
                amountSpentTextField.text = String(transaction!.getAmountOfPair() as Double)
            }else{
                transactionType = Transaction.typeReceived
                amountBoughtTextField.text = String(transaction!.getAmountOfParentCoin() as Double)
                segmentedControl.selectedSegmentIndex = 1
            }
            notesTextField.text = transaction!.getNotes() 
        }
        reloadTableView()
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
        selectedPairLabel.text = selectedFiat.uppercased()
        amountSpentLabel.text = "Amount spent (\(String(describing: selectedFiat.uppercased())))"
        if transactionType == Transaction.typeBought{
            amountBoughtLabel.text = "Amount bought (\(coin.getSymbol().uppercased()))"
            pairCell.isUserInteractionEnabled = true
            pairLabel.isEnabled = true
            amountSpentCell.isUserInteractionEnabled = true
            amountSpentLabel.isEnabled = true
        }
        else if transactionType ==  Transaction.typeReceived{
            amountBoughtLabel.text = "Amount recieved (\(coin.getSymbol().uppercased()))"
            pairCell.isUserInteractionEnabled = false
            pairLabel.isEnabled = false
            amountSpentCell.isUserInteractionEnabled = false
            amountSpentLabel.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 4{
            if let amountBought = Double(K.convertCommasToDots(amountBoughtTextField.text ?? "")){
                if transactionType == Transaction.typeBought{
                    if let amountSpent = Double(K.convertCommasToDots(amountSpentTextField.text ?? "")){
                        let newTransaction = Transaction(amountOfParentCoinBought: amountBought, boughtWith: selectedFiat, amountOfPairSpent: amountSpent)
                        if let notes = notesTextField.text{
                            newTransaction.setNotes(notes: notes)
                        }
                        if (isEditingTransaction){
                            if let navController = self.navigationController, navController.viewControllers.count >= 2 {
                                 let viewController = navController.viewControllers[navController.viewControllers.count - 2] as! TransactionDetailVC
                                viewController.transaction = newTransaction
                            }
                            
                            let date: Double = self.transaction!.getDate()
                            newTransaction.setDate(date)
                            coin.deleteTransaction(self.transaction!)
                        }
                        coin.addTransaction(newTransaction)
                        coinHandler.refresh(sender: "add transaction")
                        
                        _ = navigationController?.popViewController(animated: true)
                        
                        return
                    }
                }
                else if transactionType == Transaction.typeReceived{
                    let newTransaction = Transaction(amountReceived: amountBought)
                    if let notes = notesTextField.text{
                        newTransaction.setNotes(notes: notes)
                    }
                    if (isEditingTransaction){
                        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
                             let viewController = navController.viewControllers[navController.viewControllers.count - 2] as! TransactionDetailVC
                            viewController.transaction = newTransaction
                        }
                        
                        let date: Double = self.transaction!.getDate()
                        newTransaction.setDate(date)
                        coin.deleteTransaction(self.transaction!)
                    }
                    coin.addTransaction(newTransaction)
                    coinHandler.refresh(sender: "add transaction")

                    _ = navigationController?.popViewController(animated: true)
                    return
                }
            }
            isMissingRequiredFieldsTextVisible = true
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 4{
            if isMissingRequiredFieldsTextVisible{
                return "Missing required fields"
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
