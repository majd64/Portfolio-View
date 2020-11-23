//
//  PairTableViewVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-08.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class CurrencySettingsVC: UITableViewController, UISearchBarDelegate{
    var coinHandler: CoinHandler!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var currenciesTableView: UITableView!
    var currencies: [Currency] = []
    
    override func viewDidLoad() {
        searchBar.delegate = self
        currencies = coinHandler.getCurrencies()
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = "\(currencies[indexPath.row].getSymbol()) (\(currencies[indexPath.row].getId()))"
        if (currencies[indexPath.row]).getId() == coinHandler.getPreferredCurrency()?.getId(){
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coinHandler.setPreferredCurrencyId(to: currencies[indexPath.row].getId())
        currenciesTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currencies = coinHandler.getCurrencies().filter({$0.getSymbol().lowercased() .prefix(searchText.count) == searchText.lowercased() || $0.getId().lowercased() .prefix(searchText.count) == searchText.lowercased()})
        currenciesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        currencies = coinHandler.getCurrencies()
        currenciesTableView.reloadData()
        searchBar.resignFirstResponder()
    }
}

