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
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
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
    }
}

extension CoinVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coin.getTransactions().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionCell
        let transaction: Transaction = coin.getTransactions()[indexPath.row]
        let rate: Double = coinHandler.getPreferredExchangeRate()?.getRateUsd() ?? 1
        let symbol: String = coinHandler.getPreferredExchangeRate()?.getCurrencySymbol() ?? "$"
        cell.amountOfCoinLabel.text = "\(transaction.getAmountOfParentCoin() as String) \(coin.getSymbol())"
        let value = coin.getPrice(withRate: rate) * transaction.getAmountOfParentCoin()
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        let formattedAmountOfFiat = "\(symbol)\(numberFormatter.string(from: NSNumber(value: value)) ?? "0.00")"
        cell.amountOfFiatLabel.text = formattedAmountOfFiat
        cell.transactionTypeLabel.text = transaction.getTransactionType()
        return cell
    }
}
