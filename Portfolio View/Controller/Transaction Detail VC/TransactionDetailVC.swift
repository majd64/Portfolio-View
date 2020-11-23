//
//  TransactionDetail.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-10-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class TransactionDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var transaction: Transaction!
    var coin: Coin!
    var coinHandler: CoinHandler!
    var hasNote = false
    var numberOfCells = 0

    @IBOutlet weak var transactionDetailsTableView: UITableView!
    override func viewDidLoad() {
        transactionDetailsTableView.register(UINib(nibName: "AmountCell", bundle: nil), forCellReuseIdentifier: "amountCell")
        transactionDetailsTableView.register(UINib(nibName: "NowCell", bundle: nil), forCellReuseIdentifier: "nowCell")
        transactionDetailsTableView.register(UINib(nibName: "ThenCell", bundle: nil), forCellReuseIdentifier: "thenCell")
        transactionDetailsTableView.register(UINib(nibName: "NotesCell", bundle: nil), forCellReuseIdentifier: "notesCell")
        transactionDetailsTableView.register(UINib(nibName: "DeleteCell", bundle: nil), forCellReuseIdentifier: "deleteCell")
        
        hasNote = transaction.getNotes() != ""
        
        transactionDetailsTableView.delegate = self
        transactionDetailsTableView.dataSource = self
        super.viewDidLoad()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transaction.getTransactionType() == Transaction.typeSold || transaction.getTransactionType() == Transaction.typeBought{
            if hasNote{
                numberOfCells = 5
            }else{
                numberOfCells = 4
            }
        }
        else if transaction.getTransactionType() == Transaction.typeSent || transaction.getTransactionType() == Transaction.typeReceived{
            if hasNote{
                numberOfCells = 4
            }else{
                numberOfCells = 3
            }
        }
        else if transaction.getTransactionType() == Transaction.typeTransferredTo || transaction.getTransactionType() == Transaction.typeTransferredFrom{
            if (hasNote){
                numberOfCells = 4
            }else{
                numberOfCells = 2
            }
        }
        return numberOfCells
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 && (transaction.getTransactionType() == Transaction.typeBought || transaction.getTransactionType() == Transaction.typeSold) && transaction.getPairId() != coinHandler.getPreferredCurrency()?.getId(){
            return 100
        }
        
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let price: Double = coin.getPrice(withRate: coinHandler.getPreferredCurrency()?.getRateUsd() ?? 1) * transaction.getAmountOfParentCoin()
                
        let formattedPrice = "\(K.convertToMoneyFormat(price, symbol: coinHandler.getPreferredCurrency()?.getCurrencySymbol() ?? "$")) \(coinHandler.getPreferredCurrency()?.getSymbol() ?? "")"
        
        let amount = "\(transaction.getAmountOfParentCoin() as String) \(coin.getSymbol())"
        let amountOfPair = transaction.getAmountOfPair()
        if transaction.getTransactionType() == Transaction.typeBought || transaction.getTransactionType() == Transaction.typeSold{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "amountCell") as! AmountCell
                cell.headerLabel.text = transaction.getTransactionType() == Transaction.typeBought ? "Bought" : "Sold"
                cell.amountLabel.text = amount
                cell.amountOfPairLabel.isHidden = true
                return cell
            }
            else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.priceInPrefferedCurrencyLabel.text = formattedPrice
                if (transaction.getPairId() != coinHandler.getPreferredCurrency()?.getId()){
                    if let pair = coinHandler.getCurrency(id: transaction.getPairId()){
                        let price = coin.getPrice(withRate: pair.getRateUsd()) * transaction.getAmountOfParentCoin()
                        cell.priceInPairCurrencyLabel.text = "\(K.convertToMoneyFormat(price, symbol: pair.getCurrencySymbol())) \(pair.getSymbol())"
                    }
                }else{
                    cell.priceInPairCurrencyLabel.isHidden = true
                }
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "thenCell") as! ThenCell
                cell.headerLabel.text = transaction.getTransactionType() == Transaction.typeBought ? "Spent" : "Recieved"
                if let pair = coinHandler.getCurrency(id: transaction.getPairId()){
                    cell.amountOfPairLabel.text = "\(K.convertToMoneyFormat(amountOfPair, symbol: pair.getCurrencySymbol())) \(pair.getSymbol())"
                }
                return cell
            }else if indexPath.row == 3 && hasNote{
                let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell") as! NotesCell
                cell.notes.text = transaction.getNotes()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell")!
                return cell
            }
        }
        else if transaction.getTransactionType() == Transaction.typeReceived || transaction.getTransactionType() == Transaction.typeSent{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "amountCell") as! AmountCell
                cell.headerLabel.text = transaction.getTransactionType() == Transaction.typeReceived ? "Recieved" : "Sent"
                cell.amountLabel.text = amount
                cell.amountOfPairLabel.isHidden = true
                return cell
            }
            else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.priceInPrefferedCurrencyLabel.text = formattedPrice
                cell.priceInPairCurrencyLabel.isHidden = true
                return cell
            }else if indexPath.row == 2 && hasNote{
                let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell") as! NotesCell
                cell.notes.text = transaction.getNotes()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell")!
                return cell
            }
        }
        else {
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "amountCell") as! AmountCell
                cell.headerLabel.text = "Transfer"
                cell.amountLabel.text = transaction.getTransactionType() == Transaction.typeTransferredFrom ? "- \(amount)" : "+ \(amount)"
                if let pairCoin = coinHandler.getCoin(id: transaction.getPairId()){
                    cell.amountOfPairLabel.text = transaction.getTransactionType() == Transaction.typeTransferredFrom ? "- \(amountOfPair) \(pairCoin.getSymbol())" : "+ \(amountOfPair) \(pairCoin.getSymbol())"
                }
                return cell
            }else if indexPath.row == 1 && hasNote{
                let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell") as! NotesCell
                cell.notes.text = transaction.getNotes()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell")!
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == numberOfCells - 1{
            coin.deleteTransaction(transaction)
            coinHandler.refresh()
            _ = navigationController?.popViewController(animated: true)
        }
        
    }
}
