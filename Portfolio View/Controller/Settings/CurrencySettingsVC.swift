//
//  PairTableViewVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-08.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class CurrencySettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var coinHandler: CoinHandler!

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinHandler.getExchangeRates().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel!.text = "\(coinHandler.getExchangeRates()[indexPath.row].getSymbol()) \(coinHandler.getExchangeRates()[indexPath.row].getCurrencySymbol())"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

