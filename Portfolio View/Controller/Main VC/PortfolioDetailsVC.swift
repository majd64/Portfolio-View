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
    var portfolioPriceChanges: [Double] = []
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var portfolioPriceChangeLabel: UILabel!
    @IBOutlet weak var portfolioSecondaryPriceChangeLabel: UILabel!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        portfolioPriceChanges = coinHandler.getPortfolioPriceChange()
        
        percentages = coinHandler.getPortfolioPercentages()
        segmentedControl.selectedSegmentIndex = 0
        segmentChanged(self)
        
        
        tableView.register(UINib(nibName: "PortfolioPercentageCell", bundle: nil), forCellReuseIdentifier: "portfolioPercentageCell")
    
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
    
    
   
    @IBAction func segmentChanged(_ sender: Any) {
        if portfolioPriceChanges[segmentedControl.selectedSegmentIndex] >= 0{
            portfolioPriceChangeLabel.textColor = UIColor.systemGreen
            portfolioSecondaryPriceChangeLabel.textColor = UIColor.systemGreen
            portfolioPriceChangeLabel.text = "+\(K.convertToMoney(portfolioPriceChanges[segmentedControl.selectedSegmentIndex], currency: coinHandler.preferredCurrency))"
            portfolioSecondaryPriceChangeLabel.text = "+\(K.convertToMoney(coinHandler.convertCurrencies(from: coinHandler.preferredCurrency, to: coinHandler.secondaryCurrency, amount: portfolioPriceChanges[segmentedControl.selectedSegmentIndex]) ?? 0, currency: coinHandler.secondaryCurrency)) \(coinHandler.secondaryCurrency.uppercased())"
        }else{
            portfolioPriceChangeLabel.textColor = UIColor.systemRed
            portfolioSecondaryPriceChangeLabel.textColor = UIColor.systemRed
            portfolioPriceChangeLabel.text = "-\(K.convertToMoney(portfolioPriceChanges[segmentedControl.selectedSegmentIndex] * -1, currency: coinHandler.preferredCurrency))"
            portfolioSecondaryPriceChangeLabel.text = "-\(K.convertToMoney(coinHandler.convertCurrencies(from: coinHandler.preferredCurrency, to: coinHandler.secondaryCurrency, amount: portfolioPriceChanges[segmentedControl.selectedSegmentIndex] * -1) ?? 0, currency: coinHandler.secondaryCurrency)) \(coinHandler.secondaryCurrency.uppercased())"
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        percentages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioPercentageCell") as! PortfolioPercentageCell
        if let coin: Coin = coinHandler.getCoin(id: percentages[indexPath.row].coinID){
            cell.coinIcon.image = coin.getImage()
            cell.coinTicker.text = coin.getSymbol().uppercased()
            cell.percentage.text = String(percentages[indexPath.row].percentage) + "%"
        }
        return cell
    }
}
