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
        transactionDetailsTableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "buttonCell")
        hasNote = transaction.getNotes() != ""
        transactionDetailsTableView.delegate = self
        transactionDetailsTableView.dataSource = self
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        hasNote = transaction.getNotes() != ""
        transactionDetailsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transaction.getTransactionType() == Transaction.typeSold || transaction.getTransactionType() == Transaction.typeBought{
            if hasNote{
                numberOfCells = 7
            }else{
                numberOfCells = 6
            }
        }
        else if transaction.getTransactionType() == Transaction.typeSent || transaction.getTransactionType() == Transaction.typeReceived{
            if hasNote{
                numberOfCells = 5
            }else{
                numberOfCells = 4
            }
        }
        return numberOfCells
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let price: Double = coin.getPrice() * transaction.getAmountOfParentCoin()
                
        let formattedPrice = "\(K.convertToMoney(price, currency: coinHandler.preferredCurrency)) \(coinHandler.preferredCurrency.uppercased())"
        
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
                    cell.secondLabel.text = "\(K.convertToMoney(pairPrice ?? 0, currency: transaction.getPairId())) \(transaction.getPairId().uppercased())"
                    cell.secondLabel.isHidden = false
                }else{
                    cell.secondLabel.isHidden = true
                }
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.titleLabel.text = transaction.getTransactionType() == Transaction.typeBought ? "Spent" : "Recieved"
                cell.firstLabel.text = "\(K.convertToMoney(amountOfPair, currency: transaction.getPairId())) \(transaction.getPairId().uppercased())"
                cell.secondLabel.isHidden = true
                return cell
            }
            else if indexPath.row == 3{
                print("PAIRID: \(transaction.getPairId().lowercased())")
                print("prefcurr: \(coinHandler.preferredCurrency.lowercased())")
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowCell") as! NowCell
                cell.titleLabel.text = "Profit & loss"
                var PNLInPreferredCurrency = coin.getPrice() * transaction.getAmountOfParentCoin() - (coinHandler.convertCurrencies(from: transaction.getPairId(), to: coinHandler.preferredCurrency, amount: amountOfPair) ?? 0)
                if transaction.getTransactionType() == Transaction.typeSold{
                    PNLInPreferredCurrency *= -1
                }
                var PNLInPreferredCurrencyLabel = ""
                if PNLInPreferredCurrency < 0{
                    cell.firstLabel.textColor = UIColor.systemRed
                    cell.secondLabel.textColor = UIColor.systemRed
                    PNLInPreferredCurrencyLabel = "-\(K.convertToMoney(PNLInPreferredCurrency * -1, currency: coinHandler.preferredCurrency)) \(coinHandler.preferredCurrency.uppercased())"
                }else{
                    cell.firstLabel.textColor = UIColor.systemGreen
                    cell.secondLabel.textColor = UIColor.systemGreen
                    PNLInPreferredCurrencyLabel = "+\(K.convertToMoney(PNLInPreferredCurrency, currency: coinHandler.preferredCurrency)) \(coinHandler.preferredCurrency.uppercased())"
                }
                cell.firstLabel.text = PNLInPreferredCurrencyLabel
                if (transaction.getPairId().lowercased() != coinHandler.preferredCurrency.lowercased()){
                    let pairPrice = coinHandler.convertCurrencies(from: coinHandler.preferredCurrency, to: transaction.getPairId(), amount: price)
                    var PNLInPair = (pairPrice ?? 0) - amountOfPair
                    if transaction.getTransactionType() == Transaction.typeSold{
                        PNLInPair *= -1
                    }
                    var PNLInPairLabel = ""
                    if PNLInPair < 0{
                        PNLInPairLabel = "-\(K.convertToMoney(PNLInPair * -1, currency: transaction.getPairId())) \(transaction.getPairId().uppercased())"
                    }else{
                        PNLInPairLabel = "+\(K.convertToMoney(PNLInPair, currency: transaction.getPairId())) \(transaction.getPairId().uppercased())"
                    }
                    cell.secondLabel.text = PNLInPairLabel
                    cell.secondLabel.isHidden = false
                }else{
                    cell.secondLabel.isHidden = true
                }
                return cell
            }
            else if indexPath.row == 4 && hasNote{
                let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell") as! NotesCell
                cell.notes.text = transaction.getNotes()
                return cell
            }
            else if indexPath.row == 5 && hasNote || indexPath.row == 4 && !hasNote{
                let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonCell
                cell.label.text = "Edit transaction"
                cell.label.textColor = UIColor.orange
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonCell
                cell.label.text = "Delete transaction"
                cell.label.textColor = UIColor.red
                return cell
            }
        }
        else{//SENT/ RECEIVED
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
            }
            else if indexPath.row == 3 && hasNote || indexPath.row == 2 && !hasNote{
                let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonCell
                cell.label.text = "Edit transaction"
                cell.label.textColor = UIColor.orange

                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ButtonCell
                cell.label.text = "Delete transaction"
                cell.label.textColor = UIColor.red
                return cell
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToEditTransaction"){
            let dest = segue.destination as! TransactionVC
            dest.isEditingTransaction = true
            dest.transaction = self.transaction
            dest.coinHandler = coinHandler
            dest.coin = coin
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == numberOfCells - 1{
            coin.deleteTransaction(transaction)
            coinHandler.refresh(sender: "transaction deleted")
            _ = navigationController?.popViewController(animated: true)
        }
        else if indexPath.row == numberOfCells - 2{
            performSegue(withIdentifier: "goToEditTransaction", sender: self)
        }
    }
}
