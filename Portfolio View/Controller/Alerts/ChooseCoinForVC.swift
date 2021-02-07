//
//  chooseCoinForAlertVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-21.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class ChooseCoinForAlertVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AlertAdded {
    func alertAdded() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    var coinHandler: CoinHandler!
    var coins: [Coin] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        coins = coinHandler.getCoins()
        super.viewDidLoad()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        coins = coinHandler.getCoins().filter({$0.getSymbol().lowercased() .prefix(searchText.count) == searchText.lowercased() || $0.getName().lowercased() .prefix(searchText.count) == searchText.lowercased()})
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        coins = coinHandler.getCoins()
       
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = "\(coins[indexPath.row].getSymbol().uppercased()) (\(coins[indexPath.row].getName()))"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToAddAlert", sender: indexPath.row)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddAlert"{
            let destinationVC = segue.destination as! AddAlertVC
            destinationVC.delegate = self
            destinationVC.coin = coins[sender as! Int]
            destinationVC.coinHandler = coinHandler
        }
    }
}




