//
//  PortfolioDetailsVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-06.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class PortfolioDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var coinHandler: CoinHandler!
    var percentages: [(coinID: String, percentage: Double)] = []

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        percentages = coinHandler.getPortfolioPercentages()
        
        tableView.register(UINib(nibName: "PortfolioPercentageCell", bundle: nil), forCellReuseIdentifier: "portfolioPercentageCell")
    
        super.viewDidLoad()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        percentages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioPercentageCell") as! PortfolioPercentageCell
        if let coin: Coin = coinHandler.getCoin(id: percentages[indexPath.row].coinID){
            cell.coinIcon.image = UIImage(named: coin.getID())
            cell.coinTicker.text = coin.getSymbol()
            cell.percentage.text = String(percentages[indexPath.row].percentage) + "%"
            
        }
        
        return cell
        
    }
    
    

}
