//
//  ViewController.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var coinTableView: UITableView!
    private let myRefreshControl = UIRefreshControl()
    
    private var userRefreshTimer: Timer?
    private var autoCoinDataRefreshTimer: Timer?
    private var autoExchangeRateDataRefreshTimer: Timer?
    
    private let coinHandler = CoinHandler()

    override func viewDidLoad() {
        coinTableView.register(UINib(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")
        coinHandler.delegate = self
        coinTableView.delegate = self
        coinTableView.dataSource = self
        myRefreshControl.addTarget(self, action: #selector (ViewController.userDidRefresh), for: .valueChanged)
        coinTableView.refreshControl = myRefreshControl
        self.autoCoinDataRefreshTimer = Timer.scheduledTimer(timeInterval: 21, target: self, selector: #selector(self.requestNewCoinData), userInfo: nil, repeats: true)
        self.autoExchangeRateDataRefreshTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.requestNewExchangeRateData), userInfo: nil, repeats: true)
        initPieChart()

        super.viewDidLoad()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        coinHandler.delegate = self
        coinHandler.fetchCoinData()
        coinTableView.reloadData()
        refreshPieChartData()
    }
    
    private func refreshPieChartData(){
        let chartDataSet: PieChartDataSet = coinHandler.getPieChartDataSet()
        chartDataSet.drawValuesEnabled = false
        chartDataSet.sliceSpace = 1
        let chartData = PieChartData(dataSet: chartDataSet)
        pieChart.data = chartData
        pieChart.centerText = coinHandler.getTotalBalanceValue()
        
        var balanceAttributes: [NSAttributedString.Key: Any]!
        var balanceInBTCAttributes: [NSAttributedString.Key: Any]!
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        balanceAttributes = [
            .font: UIFont.systemFont(ofSize: 21),
            .foregroundColor: UIColor.label,
            .paragraphStyle : paragraphStyle
        ]
        balanceInBTCAttributes = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.label,
            .paragraphStyle : paragraphStyle
        ]
        
        let balanceLabel: NSMutableAttributedString = NSMutableAttributedString()
        
        if let bal = coinHandler.getTotalBalanceValue() as String?, let balBTC = coinHandler.getTotalBalanceValueInBTC() as String?{
            let balStr = NSAttributedString(string: bal, attributes: balanceAttributes)
            let balBTCStr = NSAttributedString(string: balBTC, attributes: balanceInBTCAttributes)
            balanceLabel.append(balStr)
            balanceLabel.append(NSAttributedString(string: "\n"))
            balanceLabel.append(balBTCStr)
        }else{
            let noBalance = NSAttributedString(string: "No Balance", attributes: balanceAttributes)
            balanceLabel.append(noBalance)
        }
        pieChart.centerAttributedText = balanceLabel
    }
    
    private func initPieChart(){
        pieChart.holeColor = UIColor.clear
        pieChart.isUserInteractionEnabled = false
        pieChart.legend.enabled = false
        pieChart.holeRadiusPercent = 0.94
        refreshPieChartData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToCoin"){
            if let sender: Coin = sender as? Coin{
                let destinationVC = segue.destination as! CoinVC
                destinationVC.coin = sender
                destinationVC.coinHandler = coinHandler
            }
        }
        else if (segue.identifier == "goToSettingsVC"){
            let destinationVC = segue.destination as! SettingsVC
            destinationVC.coinHandler = coinHandler
        }
    }
}

// MARK: Table View Delegate & Data Source
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinHandler.getCoins().count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCoin", sender: coinHandler.getCoins()[indexPath.row])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell") as! CoinCell
        let coin: Coin = coinHandler.getCoins()[indexPath.row]
        let rate: Double = coinHandler.getPreferredExchangeRate()?.getRateUsd() ?? 1
        let symbol: String = coinHandler.getPreferredExchangeRate()?.getCurrencySymbol() ?? "$"
        
        cell.cellView.layer.cornerRadius = 15
        cell.iconImage.image = UIImage(named: coin.getID())
        
        cell.cellView.backgroundColor = UIImage(named: coin.getID())?.averageColor?.withAlphaComponent(0.5) ?? UIColor.gray.withAlphaComponent(0.50)
        cell.nameLabel.text = coin.getName()
        cell.symbolLabel.text = coin.getSymbol()
        cell.priceLabel.text = coin.getPrice(withRate: rate, symbol: symbol)
        cell.balanceLabel.text = coin.getBalance()
        cell.balanceValueLabel.text = coin.getBalanceValue(withRate: rate, symbol: symbol)
        cell.h24ChangeLabel.text = coin.getChangePercent24Hr()
        
        return cell
    }
}

//MARK: Refresh Handler
extension ViewController{
    @objc func userDidRefresh(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.myRefreshControl.endRefreshing()
        }
    }
    
    @objc func requestNewCoinData(){
        coinHandler.fetchCoinData()
    }
    
    @objc func requestNewExchangeRateData(){
        coinHandler.fetchExchangeRateData()
    }
}

//MARK: Coin Handler Delegate
extension ViewController: CoinHandlerDelegate{
    func didUpdateExchangeRatesData() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.coinTableView.reloadData()
            self.refreshPieChartData()
        }
    }
    
    func didUpdateCoinsData() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.coinTableView.reloadData()
            self.refreshPieChartData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
