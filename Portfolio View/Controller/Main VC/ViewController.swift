//
//  ViewController.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController, ChartViewDelegate, CanRefresh {
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var coinTableView: UITableView!
    private let myRefreshControl = UIRefreshControl()
    
    private var userRefreshTimer: Timer?
    private var autoCoinDataRefreshTimer: Timer?
    private let defaults = UserDefaults.standard
    private var coloredCellsEnabled = false
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    private let coinHandler = CoinHandler()

    override func viewDidLoad() {
        coloredCellsEnabled = self.defaults.bool(forKey: "coloredCells")
        if self.coloredCellsEnabled{
            self.blur.isHidden = false
        }else{
            self.blur.isHidden = true
        }
        refresh()
        coinTableView.register(UINib(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")
        coinHandler.delegate = self
        coinHandler.refreshDelegate = self
        coinTableView.delegate = self
        coinTableView.dataSource = self
        pieChart.delegate = self
        myRefreshControl.addTarget(self, action: #selector (ViewController.userDidRefresh), for: .valueChanged)
        coinTableView.refreshControl = myRefreshControl
        self.autoCoinDataRefreshTimer = Timer.scheduledTimer(timeInterval: 21, target: self, selector: #selector(self.requestNewCoinData), userInfo: nil, repeats: true)
        initPieChart()
        spinner.isHidden = true
        if !coinHandler.didInit{
            spinner.isHidden = false
            spinner.startAnimating()
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
        coinHandler.delegate = self
    }
    
    private func refreshPieChartData(){
        let chartDataSet: PieChartDataSet = coinHandler.getPieChartDataSet()
        chartDataSet.drawValuesEnabled = false
        chartDataSet.sliceSpace = 1.7
        let chartData = PieChartData(dataSet: chartDataSet)
        pieChart.data = chartData
        pieChart.centerText = K.convertToMoneyFormat(coinHandler.getTotalBalanceValue(), currency: coinHandler.preferredCurrency)
        
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
        
        
        
        let balStr = NSAttributedString(string: K.convertToMoneyFormat(coinHandler.getTotalBalanceValue(), currency: coinHandler.preferredCurrency), attributes: balanceAttributes)
        let balSecondaryStr = NSAttributedString(string: "\(K.convertToMoneyFormat(coinHandler.convertCurrencies(from: coinHandler.preferredCurrency, to: coinHandler.secondaryCurrency, amount: coinHandler.getTotalBalanceValue()) ?? 0, currency: coinHandler.secondaryCurrency)) \(coinHandler.secondaryCurrency.uppercased())" , attributes: balanceInBTCAttributes)
        balanceLabel.append(balStr)
        balanceLabel.append(NSAttributedString(string: "\n"))
        balanceLabel.append(balSecondaryStr)
        
        pieChart.centerAttributedText = balanceLabel
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        pieChart.highlightValue(nil)
        performSegue(withIdentifier: "goToPortfolioDetails", sender: self)
    }
    
    private func initPieChart(){
        pieChart.holeColor = UIColor.clear
        pieChart.legend.enabled = false
        pieChart.holeRadiusPercent = 0.97
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
        
        else if (segue.identifier == "goToPortfolioDetails"){
            let destinationVC = segue.destination as! PortfolioDetailsVC
            destinationVC.coinHandler = coinHandler
        }
        else if (segue.identifier == "goToAlerts"){
            let destinationVC = segue.destination as! AlertsVC
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
        
        cell.cellView.layer.cornerRadius = 15
        cell.iconImage.image = coin.getImage()
        
        if coloredCellsEnabled{
            cell.cellView.backgroundColor = coin.getColor()
//          backgroundView.backgroundColor = colors.background
//          mainLabel.textColor = colors.primary
//          secondaryLabel.textColor = colors.secondary
//          detailLabel.textColor = colors.detail
        }else{
            cell.cellView.backgroundColor = UIColor(named: "Color")
        }
        cell.nameLabel.text = coin.getName()
        cell.symbolLabel.text = coin.getSymbol().uppercased()
        cell.priceLabel.text = K.convertToCoinPrice(coin.getPrice(), currency: coinHandler.preferredCurrency)
        cell.balanceLabel.text = coin.getBalance()
        cell.balanceValueLabel.text = K.convertToMoneyFormat(coin.getBalanceValue(), currency: coinHandler.preferredCurrency)
        cell.h24ChangeLabel.text = coin.getChangePercentage24h()
        
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
}

//MARK: Coin Handler Delegate
extension ViewController: CoinHandlerDelegate{
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.coloredCellsEnabled = self.defaults.bool(forKey: "coloredCells")
            if self.coloredCellsEnabled{
                self.blur.isHidden = false
            }else{
                self.blur.isHidden = true
            }
            
            self.refreshPieChartData()
            self.coinTableView.reloadData()
        }
    }
    
    func didUpdateCurrencyData() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.coinTableView.reloadData()
            self.refreshPieChartData()
        }
    }
    
    func didUpdateCoinsData() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.coinTableView.reloadData()
            self.refreshPieChartData()
            if self.coinHandler.didInit{
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didFetchCoinPrice(price: Double) {}
    
    
}

