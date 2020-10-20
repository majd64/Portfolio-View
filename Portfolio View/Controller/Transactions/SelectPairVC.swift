//
//  PairTableViewVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-08.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class SelectPairVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var coin: Coin!
    var coinHandler: CoinHandler!
    var sender: Any!
        
        
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
       
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sender is AddBuyTransactionVC || sender is AddSellTransactionVC{
            return coinHandler.getExchangeRates().count
        }
        else{
            return coinHandler.getCoins().count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if sender is AddBuyTransactionVC || sender is AddSellTransactionVC{
            cell.textLabel!.text = "\(coin.getSymbol()) : \(coinHandler.getExchangeRates()[indexPath.row].getSymbol())"
        }
        else{
            cell.textLabel!.text = coinHandler.getCoins()[indexPath.row].getSymbol()
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let send = sender as? AddBuyTransactionVC{
            send.selectedFiat = coinHandler.getExchangeRates()[indexPath.row]
            _ = navigationController?.popViewController(animated: true)
        }
        else if let send = sender as? AddSellTransactionVC{
            send.selectedFiat = coinHandler.getExchangeRates()[indexPath.row]
            _ = navigationController?.popViewController(animated: true)
        }
        else if let send = sender as? AddTransferTransactionVC{
            send.otherCoin = coinHandler.getCoins()[indexPath.row]
            _ = navigationController?.popViewController(animated: true)
        }
    }
}
