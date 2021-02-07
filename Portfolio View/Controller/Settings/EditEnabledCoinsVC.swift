//
//  EditEnabledCoinsVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-12-16.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class EditEnabledCoinsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, EditCoinsDelegate {
    
    
    var coinHandler: CoinHandler!
    @IBOutlet weak var tableView: UITableView!
    var availbleCoins: [AvailbleCoin] = []
    
    var enabledCoins: [String] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.register(UINib(nibName: "AvailbleCoinCell", bundle: nil), forCellReuseIdentifier: "availbleCoinCell")
        availbleCoins = coinHandler.getAvailbleCoins()
        searchBar.placeholder = "\(availbleCoins.count) coins availble"
        enabledCoins = coinHandler.enabledCoinIdsArray
        super.viewDidLoad()
    }
    @IBAction func disclaimerButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Enabling more than 200 coins may cause a minor decrease in the apps performance. We are working to fix this.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func buttonPressed(_ val: Int) {
        var numberOfCoins = 0
        var disabledAll: Bool = false
        switch val{
        case 0:
            numberOfCoins = 100
        case 1:
            numberOfCoins = 50
        case 2:
            numberOfCoins = 25
        default:
            disabledAll = true
        }
        if (!disabledAll){
            for i in 0..<numberOfCoins{
                if !enabledCoins.contains(availbleCoins[i].id){
                    enabledCoins.append(availbleCoins[i].id)
                }
            }
            for i in numberOfCoins..<availbleCoins.count - 1{
                if enabledCoins.contains(availbleCoins[i].id){
                    enabledCoins.remove(at: enabledCoins.firstIndex(of: availbleCoins[i].id)!)
                }
            }
        }else{
            for coinId: String in enabledCoins{
                if let coin = coinHandler.getCoin(id: coinId){
                    if (coin.getBalance() == 0){
                        enabledCoins.remove(at: enabledCoins.firstIndex(of: coinId)!)
                    }
                }else{
                    enabledCoins.remove(at: enabledCoins.firstIndex(of: coinId)!)
                }
            }
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availbleCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "availbleCoinCell") as! AvailbleCoinCell
            
            cell.label.text = "\(availbleCoins[indexPath.row].symbol?.uppercased() ?? "") (\(availbleCoins[indexPath.row].name ?? ""))"
            
            cell.enabledSwitch.tag = indexPath.row
            cell.enabledSwitch.addTarget(self, action: #selector(toggled), for: .valueChanged)
            
            if (enabledCoins.contains(availbleCoins[indexPath.row].id)){
                cell.enabledSwitch.isOn = true
                if let coin = coinHandler?.getCoin(id: availbleCoins[indexPath.row].id){
                    if coin.getBalance() != 0{
                        cell.enabledSwitch.isEnabled = false
                    }else{
                        cell.enabledSwitch.isEnabled = true
                    }
                    
                }
            }else{
                cell.enabledSwitch.isEnabled = true
                cell.enabledSwitch.isOn = false
            }
            return cell
             
        
    }
    
    @objc func toggled(sender: UISwitch) {
        if (sender.isOn){
            enabledCoins.append(availbleCoins[sender.tag].id)
        }else{
            if let index = enabledCoins.firstIndex(of: availbleCoins[sender.tag].id){
                enabledCoins.remove(at: index)
            }
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        availbleCoins = coinHandler.getAvailbleCoins().filter({$0.symbol!.lowercased() .prefix(searchText.count) == searchText.lowercased() || $0.name!.lowercased() .prefix(searchText.count) == searchText.lowercased()})
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        availbleCoins = coinHandler.getAvailbleCoins()
       
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            coinHandler.updateEnabledCoinIdsArray(newArray: enabledCoins)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToEditEnabledCoinsContainer"){
            let destVC = segue.destination as! EditEnabledCoinsContainer
            destVC.delegate = self
            destVC.coinHandler = coinHandler
            
        }
    }
    

}


