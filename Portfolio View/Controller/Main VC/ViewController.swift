//
//  ViewController.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var coinTableView: UITableView!
    private let myRefreshControl = UIRefreshControl()
        
    @IBOutlet weak var bgImage: UIImageView!
    private var userRefreshTimer: Timer?
    private var autoCoinDataRefreshTimer: Timer?
    private let defaults = UserDefaults.standard
    private var coloredCellsEnabled = false
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    private let coinHandler = CoinHandler()
    
    override func viewDidLoad() {
        coinTableView.register(UINib(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")
        coinHandler.delegate = self
        CoinHandler.globalRefreshDelegate = self
        coinTableView.delegate = self
        coinTableView.dataSource = self
        pieChart.delegate = self
        myRefreshControl.addTarget(self, action: #selector (ViewController.userDidRefresh), for: .valueChanged)
        coinTableView.refreshControl = myRefreshControl
        self.autoCoinDataRefreshTimer = Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(self.requestNewCoinData), userInfo: nil, repeats: true)
        initPieChart()
        coinHandler.sortCoins(sender: "view did load main vc")
        coinHandler.fetchCoinData(lightRefresh: false)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        spinner.isHidden = true
        coinHandler.delegate = self
        if (self.defaults.string(forKey: "didAddFirstTransaction") == nil && coinHandler.getTotalBalanceValue() != 0){
                defaults.setValue(true, forKey: "didAddFirstTransaction")
                let alert = UIAlertController(title: nil, message: "Click the piew chart for a detailed overview of your portfolio", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
                self.present(alert, animated: true)
        }
        
        if (!self.defaults.bool(forKey: "didPromptNewFeaturesForV3")){
            defaults.setValue(true, forKey: "didPromptNewFeaturesForV3")
            let alert = UIAlertController(title: nil, message: "Add more coins from the settings page", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        switch coinHandler.appearance{
        case "dark":
            overrideUserInterfaceStyle = .dark
            self.navigationController?.overrideUserInterfaceStyle = .dark
        case "light":
            coinHandler.appearance = "light"
            overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        default:
            coinHandler.appearance = "auto"
            overrideUserInterfaceStyle = .unspecified
            self.navigationController?.overrideUserInterfaceStyle = .unspecified
        }
        
        bgImage.alpha = 1
        if self.traitCollection.userInterfaceStyle == .dark{
            if coinHandler.darkImageType == "preset"{
                bgImage.image = UIImage(named: "Background")
            }
            else if coinHandler.darkImageType == "customImage"{
                bgImage.image = coinHandler.darkCustomImage
            }
            else if coinHandler.darkImageType == "customImageColor"{
                if let col = coinHandler.darkCustomImageColor{
                    bgImage.alpha = 0
                    view.backgroundColor = K.hexStringToUIColor(hex: col)
                }
            }
        }else{
            if coinHandler.lightImageType == "preset"{
                bgImage.image = UIImage(named: "Background")
            }
            else if coinHandler.lightImageType == "customImage"{
                bgImage.image = coinHandler.lightCustomImage
            }
            else if coinHandler.lightImageType == "customImageColor"{
                if let col = coinHandler.lightCustomImageColor{
                    bgImage.alpha = 0
                    view.backgroundColor = K.hexStringToUIColor(hex: col)
                }
            }
        }
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        coinTableView.reloadData()
        
        if (coinHandler.shouldSpin()){
            coinHandler.deleteUnenabledCoins()
            coinTableView.isScrollEnabled = false
            coinTableView.isUserInteractionEnabled = false
            spinner.isHidden = false
            spinner.startAnimating()
        }
        super.viewDidAppear(true)
    }
    


    @IBAction func bellButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToAlerts", sender: self)
    }
    @IBAction func gearButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToSettingsVC", sender: self)
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
extension ViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        let cellColor: UIColor!
        if (self.traitCollection.userInterfaceStyle == .dark){
            cellColor = K.hexStringToUIColor(hex: coinHandler.darkCellColor).withAlphaComponent(CGFloat(coinHandler.darkCellColorAlpha))
        }else{
            cellColor = K.hexStringToUIColor(hex: coinHandler.lightCellColor).withAlphaComponent(CGFloat(coinHandler.lightCellColorAlpha))
        }
        
        cell.cellView.backgroundColor = cellColor
        cell.cellView.layer.cornerRadius = 15
        cell.iconImage.image = coin.getImage()
        
        cell.nameLabel.text = coin.getName()
        cell.symbolLabel.text = coin.getSymbol().uppercased()
        cell.priceLabel.text = K.convertToCoinPrice(coin.getPrice(), currency: coinHandler.preferredCurrency)
        cell.balanceLabel.text = coin.getBalance()
        cell.balanceValueLabel.text = K.convertToMoney(coin.getBalanceValue(), currency: coinHandler.preferredCurrency)
        cell.h24ChangeLabel.text = coin.getChangePercentage24h()
        
        if cellColor.isLight(){
            cell.nameLabel.textColor = UIColor.black
            cell.symbolLabel.textColor = UIColor.black
            cell.priceLabel.textColor = UIColor.black
            cell.balanceLabel.textColor = UIColor.black
            cell.balanceValueLabel.textColor = UIColor.black
            cell.h24ChangeLabel.textColor = UIColor.black
        }else{
            cell.nameLabel.textColor = UIColor.white
            cell.symbolLabel.textColor = UIColor.white
            cell.priceLabel.textColor = UIColor.white
            cell.balanceLabel.textColor = UIColor.white
            cell.balanceValueLabel.textColor = UIColor.white
            cell.h24ChangeLabel.textColor = UIColor.white
        }
        return cell
    }

    func refresh(sender: String) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.refreshPieChartData()
            self.coinTableView.reloadData()

            if (!self.coinHandler.shouldSpin()){
                self.coinTableView.isScrollEnabled = true
                self.coinTableView.isUserInteractionEnabled = true
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
            }
        }
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
        coinHandler.fetchCoinData(lightRefresh: false)
    }
}

//MARK: Coin Handler Delegate
extension ViewController: CoinHandlerDelegate{
    
    func requestRefresh() {
        coinHandler.fetchCoinData(lightRefresh: true)
    }
    
    func didFailWithError(error: Error) {}
    func didFetchCoinPrice(price: Double) {}
}

//MARK: Pie Chart
extension ViewController{
    private func initPieChart(){
        pieChart.holeColor = UIColor.clear
        pieChart.legend.enabled = false
        pieChart.holeRadiusPercent = 0.98
        pieChart.rotationEnabled = false
        refreshPieChartData()
    }

    private func refreshPieChartData(){
        let chartDataSet: PieChartDataSet = coinHandler.getPieChartDataSet()
        chartDataSet.drawValuesEnabled = false
        chartDataSet.sliceSpace = 1.7
        let chartData = PieChartData(dataSet: chartDataSet)
        pieChart.data = chartData

        var balanceAttributes: [NSAttributedString.Key: Any]!
        var balanceInBTCAttributes: [NSAttributedString.Key: Any]!
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        balanceAttributes = [
            .font: UIFont.systemFont(ofSize: 21, weight: .regular),
            .foregroundColor: UIColor.label,
            .paragraphStyle : paragraphStyle
        ]
        balanceInBTCAttributes = [
            .font: UIFont.systemFont(ofSize: 15, weight: .light),
            .foregroundColor: UIColor.label,
            .paragraphStyle : paragraphStyle
        ]
                
        let balanceLabel: NSMutableAttributedString = NSMutableAttributedString()
        let balStr = NSAttributedString(string: K.convertToMoney(coinHandler.getTotalBalanceValue(), currency: coinHandler.preferredCurrency), attributes: balanceAttributes)
        let balSecondaryStr = NSAttributedString(string: "\(K.convertToMoney(coinHandler.convertCurrencies(from: coinHandler.preferredCurrency, to: coinHandler.secondaryCurrency, amount: coinHandler.getTotalBalanceValue()) ?? 0, currency: coinHandler.secondaryCurrency)) \(coinHandler.secondaryCurrency.uppercased())" , attributes: balanceInBTCAttributes)
        balanceLabel.append(balStr)
        balanceLabel.append(NSAttributedString(string: "\n"))
        balanceLabel.append(balSecondaryStr)
        pieChart.centerAttributedText = balanceLabel
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        pieChart.highlightValue(nil)
        performSegue(withIdentifier: "goToPortfolioDetails", sender: self)
    }
}
