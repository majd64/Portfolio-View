//
//  TransactionDetail.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-10-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class TransactionDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CoinHandlerDelegate {
    var transaction: Transaction!
    var coin: Coin!
    var coinHandler: CoinHandler!
    var hasNote = false
    var numberOfCells = 0
    
    
    var pairPrice: Double = 0

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
        coinHandler.delegate = self
        
        if (transaction.getPairId() != coinHandler.preferredCurrency){
            coinHandler.fetchCoinPrice(coinID: coin.getID(), currency: transaction.getPairId())
        }
        
        
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
    
        
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let price: Double = coin.getPrice() * transaction.getAmountOfParentCoin()
                
        let formattedPrice = "\(K.convertToMoneyFormat(price, currency: coinHandler.preferredCurrency))"
        
        let amount = "\(transaction.getAmountOfParentCoin() as String) \(coin.getSymbol().uppercased())"
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
                if (transaction.getPairId() != coinHandler.preferredCurrency){
                    let price = pairPrice * transaction.getAmountOfParentCoin()
                    cell.priceInPairCurrencyLabel.text = "\(K.convertToMoneyFormat(price, currency: transaction.getPairId())) \(transaction.getPairId().uppercased())"
                    
                    
                }else{
                    cell.priceInPairCurrencyLabel.isHidden = true
                }
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "thenCell") as! ThenCell
                cell.headerLabel.text = transaction.getTransactionType() == Transaction.typeBought ? "Spent" : "Recieved"
                cell.amountOfPairLabel.text = "\(K.convertToMoneyFormat(amountOfPair, currency: transaction.getPairId()))"
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
                    cell.amountOfPairLabel.text = transaction.getTransactionType() == Transaction.typeTransferredFrom ? "- \(amountOfPair) \(pairCoin.getSymbol().uppercased())" : "+ \(amountOfPair) \(pairCoin.getSymbol().uppercased())"
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
    
    func didUpdateCoinsData() {}
    
    func didFetchCoinPrice(price: Double) {
        pairPrice = price
        transactionDetailsTableView.reloadData()
    }
    
    func didFailWithError(error: Error) {}
}
