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
        transactionDetailsTableView.register(UINib(nibName: "NowCell", bundle: nil), forCellReuseIdentifier: "nowCell")
        transactionDetailsTableView.register(UINib(nibName: "NotesCell", bundle: nil), forCellReuseIdentifier: "notesCell")
        transactionDetailsTableView.register(UINib(nibName: "DeleteCell", bundle: nil), forCellReuseIdentifier: "deleteCell")
        hasNote = transaction.getNotes() != ""
        transactionDetailsTableView.delegate = self
        transactionDetailsTableView.dataSource = self
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if coinHandler.appearance == "dark"{
            overrideUserInterfaceStyle = .dark
            self.navigationController?.overrideUserInterfaceStyle = .dark
        }
        else if coinHandler.appearance == "light"{
            overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }else{
            overrideUserInterfaceStyle = .unspecified
            self.navigationController?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transaction.getTransactionType() == Transaction.typeSold || transaction.getTransactionType() == Transaction.typeBought{
            if hasNote{
                numberOfCells = 6
            }else{
                numberOfCells = 5
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let price: Double = coin.getPrice() * transaction.getAmountOfParentCoin()
                
        let formattedPrice = "\(K.convertToMoneyFormat(price, currency: coinHandler.preferredCurrency)) \(coinHandler.preferredCurrency.uppercased())"
        
        let amount = "\(transaction.getAmountOfParentCoin() as String) \(coin.getSymbol().uppercased())"
        let amountOfPair = transaction.getAmountOfPair()
        if transaction.getTransactionType() == Transaction.typeBought || transaction.getTransactionType() == Transaction.typeSold{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.titleLabel.text = transaction.getTransactionType() == Transaction.typeBought ? "Bought" : "Sold"
                if self.traitCollection.userInterfaceStyle == .dark {
                    cell.firstLabel.textColor = coin.getColor().lighter()
                }else{
                    cell.firstLabel.textColor = coin.getColor().darker()
                }
                cell.firstLabel.text = amount
                
                cell.secondLabel.isHidden = true
                return cell
            }
            else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.titleLabel.text = "Current price"
                cell.firstLabel.text = formattedPrice
                if (transaction.getPairId().lowercased() != coinHandler.preferredCurrency.lowercased()){
                    let pairPrice = coinHandler.convertCurrencies(from: coinHandler.preferredCurrency, to: transaction.getPairId(), amount: price)
                    cell.secondLabel.text = "\(K.convertToMoneyFormat(pairPrice ?? 0, currency: transaction.getPairId())) \(transaction.getPairId().uppercased())"
                }else{
                    cell.secondLabel.isHidden = true
                }
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.titleLabel.text = transaction.getTransactionType() == Transaction.typeBought ? "Spent" : "Recieved"
                cell.secondLabel.text = "\(K.convertToMoneyFormat(amountOfPair, currency: transaction.getPairId())) \(transaction.getPairId().uppercased())"
                cell.secondLabel.isHidden = true
                return cell
            }
            else if indexPath.row == 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.titleLabel.text = "Profit & loss"
                let PNLInPreferredCurrency = coin.getPrice() * transaction.getAmountOfParentCoin() - (coinHandler.convertCurrencies(from: transaction.getPairId(), to: coinHandler.preferredCurrency, amount: amountOfPair) ?? 0)
                var PNLInPreferredCurrencyLabel = ""
                if PNLInPreferredCurrency < 0{
                    cell.firstLabel.textColor = UIColor.systemRed
                    cell.secondLabel.textColor = UIColor.systemRed
                    PNLInPreferredCurrencyLabel = "-\(K.convertToMoneyFormat(PNLInPreferredCurrency * -1, currency: coinHandler.preferredCurrency)) \(coinHandler.preferredCurrency.uppercased())"
                }else{
                    cell.firstLabel.textColor = UIColor.systemGreen
                    cell.secondLabel.textColor = UIColor.systemGreen
                    PNLInPreferredCurrencyLabel = "+\(K.convertToMoneyFormat(PNLInPreferredCurrency, currency: coinHandler.preferredCurrency)) \(coinHandler.preferredCurrency.uppercased())"
                }
                cell.firstLabel.text = PNLInPreferredCurrencyLabel
                if (transaction.getPairId().lowercased() != coinHandler.preferredCurrency.lowercased()){
                    let pairPrice = coinHandler.convertCurrencies(from: coinHandler.preferredCurrency, to: transaction.getPairId(), amount: price)
                    let PNLInPair = (pairPrice ?? 0) - amountOfPair
                    var PNLInPairLabel = ""
                    if PNLInPair < 0{
                        PNLInPairLabel = "-\(K.convertToMoneyFormat(PNLInPair * -1, currency: transaction.getPairId())) \(transaction.getPairId().uppercased())"
                    }else{
                        PNLInPairLabel = "+\(K.convertToMoneyFormat(PNLInPair, currency: transaction.getPairId())) \(transaction.getPairId().uppercased())"
                    }
                    cell.secondLabel.text = PNLInPairLabel
                }else{
                    cell.secondLabel.isHidden = true
                }
                return cell
            }
            else if indexPath.row == 4 && hasNote{
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.titleLabel.text = transaction.getTransactionType() == Transaction.typeReceived ? "Recieved" : "Sent"
                if self.traitCollection.userInterfaceStyle == .dark {
                    cell.firstLabel.textColor = coin.getColor().lighter()
                }else{
                    cell.firstLabel.textColor = coin.getColor().darker()
                }
                cell.firstLabel.text = amount
                cell.secondLabel.isHidden = true
                return cell
            }
            else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.firstLabel.text = formattedPrice
                cell.secondLabel.isHidden = true
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.titleLabel.text = "Transfer"
                cell.firstLabel.text = transaction.getTransactionType() == Transaction.typeTransferredFrom ? "- \(amount)" : "+ \(amount)"
                if let pairCoin = coinHandler.getCoin(id: transaction.getPairId()){
                    cell.secondLabel.text = transaction.getTransactionType() == Transaction.typeTransferredFrom ? "+ \(amountOfPair) \(pairCoin.getSymbol().uppercased())" : "- \(amountOfPair) \(pairCoin.getSymbol().uppercased())"
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
