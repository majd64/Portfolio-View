//
//  CoinViewController.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-30.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import Charts

class CoinVC: UIViewController{

    var coin: Coin!
    var coinHandler: CoinHandler!
    @IBOutlet weak var transactionsTableView: UITableView!
    
    override func viewDidLoad() {
        transactionsTableView.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "transactionCell")
        transactionsTableView.register(UINib(nibName: "CoinBalanceCell", bundle: nil), forCellReuseIdentifier: "coinBalanceCell")
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.contentInsetAdjustmentBehavior = .never
    
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.transactionsTableView.reloadData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToContainerVC"{
            let destinationVC = segue.destination as! ContainerVC
            destinationVC.coin = coin
            destinationVC.coinHandler = coinHandler
        }
        else if segue.identifier == "goToAddTransaction"{
            let destinationVC = segue.destination as! TransactionVC
            destinationVC.coin = coin
            destinationVC.coinHandler = coinHandler
        }
        
        else if (segue.identifier == "goToTransactionDetails"){
           if let transaction: Transaction = sender as? Transaction{
               let destinationVC = segue.destination as! TransactionDetailVC
               destinationVC.transaction = transaction
               destinationVC.coinHandler = coinHandler
               destinationVC.coin = coin
           }
       }
    }
}

extension CoinVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coin.getTransactions().count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0){
            return 65
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: self.transactionsTableView.frame.size.width, height: 1)
        let line = UIView(frame: frame)
        line.backgroundColor = UIColor.systemBackground

        return line
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row) == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "coinBalanceCell") as! CoinBalanceCell
            cell.balanceLabel.text = coin.getBalance()
            
            cell.valueLabel.text = K.convertToMoney(coin.getBalanceValue(), currency: coinHandler.preferredCurrency)
      
            return cell
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionCell
        let transaction: Transaction = coin.getTransactions()[indexPath.row - 1]
        cell.amountOfCoinLabel.text = "\(transaction.getAmountOfParentCoin() as String) \(coin.getSymbol().uppercased())"
        let value = coin.getPrice() * transaction.getAmountOfParentCoin()
        let formattedAmountOfFiat = K.convertToCoinPrice(value, currency: coinHandler.preferredCurrency)
        cell.amountOfFiatLabel.text = formattedAmountOfFiat
        cell.transactionTypeLabel.text = transaction.getTransactionTypeName()
        if transaction.getTransactionType() == Transaction.typeSold || transaction.getTransactionType() == Transaction.typeSent || transaction.getTransactionType() == Transaction.typeTransferredFrom{
            cell.transactionTypeSymbolImage.image = UIImage(systemName: "arrow.up.right")
        }
        else if transaction.getTransactionType() == Transaction.typeBought || transaction.getTransactionType() == Transaction.typeReceived || transaction.getTransactionType() == Transaction.typeTransferredFrom{
            cell.transactionTypeSymbolImage.image = UIImage(systemName: "arrow.down.left")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row != 0){
            transactionsTableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "goToTransactionDetails", sender: coin.getTransactions()[indexPath.row - 1])
        }
        
    }
}
