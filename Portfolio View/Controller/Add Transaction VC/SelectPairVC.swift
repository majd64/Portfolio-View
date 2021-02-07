//
//  PairTableViewVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-08.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class SelectPairVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var coin: Coin!
    var coinHandler: CoinHandler!
    var sender: Any!
    var currencies: [String] = []
    var coins: [Coin] = []
    var isTransfer = false
        
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        if sender is AddBuyTransactionVC || sender is AddSellTransactionVC{
            isTransfer = false
        }else{
            isTransfer = true
        }
        
        if (isTransfer){
            coins = coinHandler.getCoins()
        }else{
            currencies = coinHandler.getCurrencies()
        }
        
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("text did change")
        if (isTransfer){
            coins = coinHandler.getCoins().filter({$0.getSymbol().lowercased() .prefix(searchText.count) == searchText.lowercased() || $0.getName().lowercased() .prefix(searchText.count) == searchText.lowercased()})
        }else{
            currencies = coinHandler.getCurrencies().filter({$0.lowercased() .prefix(searchText.count) == searchText.lowercased() })
        }
       
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        if (isTransfer){
            coins = coinHandler.getCoins()
        }else{
            currencies = coinHandler.getCurrencies()
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTransfer{
            return coins.count
        }
        else{
            return currencies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if sender is AddBuyTransactionVC || sender is AddSellTransactionVC{
            cell.textLabel!.text = "\(currencies[indexPath.row].uppercased())"
        }
        else{
            cell.textLabel!.text = "\(coins[indexPath.row].getSymbol().uppercased()) (\(coins[indexPath.row].getName()))"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let send = sender as? AddBuyTransactionVC{
            send.selectedFiat = currencies[indexPath.row]
            _ = navigationController?.popViewController(animated: true)
        }
        else if let send = sender as? AddSellTransactionVC{
            send.selectedFiat = currencies[indexPath.row]
            _ = navigationController?.popViewController(animated: true)
        }
    }
}
