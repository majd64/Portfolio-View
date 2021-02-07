//
//  ContainerVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-11.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import Charts

class ContainerVC: UIViewController, CoinHandlerDelegate, ChartViewDelegate{
    func requestRefresh() {
        coinHandler.fetchCoinData(lightRefresh: false)
    }
    
    var coin: Coin!
    var coinHandler: CoinHandler!
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceValueLabel: UILabel!
    @IBOutlet weak var h24ChangeLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pinnedButton: UIButton!
    
    private var selectedTimeFrameIndex = 0
    var homeScreen: ViewController!
    
    let generator = UIImpactFeedbackGenerator(style: .light)
                
    
    private var lineChartDataSets: [(timeFrame: String, data: LineChartData?, change: Double, high: Double, low: Double)] = [
        (timeFrame: "1D", data: nil, change: 0, high: 0, low: 0),
        (timeFrame: "1W", data: nil, change: 0, high: 0, low: 0),
        (timeFrame: "1M", data: nil, change: 0, high: 0, low: 0),
        (timeFrame: "3M", data: nil, change: 0, high: 0, low: 0),
        (timeFrame: "6M", data: nil, change: 0, high: 0, low: 0),
        (timeFrame: "1Y", data: nil, change: 0, high: 0, low: 0),
        (timeFrame: "MAX", data: nil, change: 0, high: 0, low: 0)]
    
    private let symbolConfig = UIImage.SymbolConfiguration(scale: .large)
        
    override func viewDidLoad() {
        lineChartDataSets = [
            (timeFrame: "1D", data: nil, change: 0, high: 0, low: 0),
            (timeFrame: "1W", data: nil, change: 0, high: 0, low: 0),
            (timeFrame: "1M", data: nil, change: 0, high: 0, low: 0),
            (timeFrame: "3M", data: nil, change: 0, high: 0, low: 0),
            (timeFrame: "6M", data: nil, change: 0, high: 0, low: 0),
            (timeFrame: "1Y", data: nil, change: 0, high: 0, low: 0),
            (timeFrame: "MAX", data: nil, change: 0, high: 0, low: 0)]
        coinHandler.secondaryDelegate = self
        coinHandler.lineChartDelegate = self
        lineChart.delegate = self
        segmentedControl.selectedSegmentIndex = selectedTimeFrameIndex
        initLineChart()
        iconImage.image = coin.getImage()
        symbolLabel.text = coin.getSymbol().uppercased()
        priceLabel.text = K.convertToCoinPrice(coin.getPrice(), currency: coinHandler.preferredCurrency)
        
        if (coin.getPinned()){
            pinnedButton.setImage(UIImage(systemName: "star.fill", withConfiguration: symbolConfig), for: .normal)
        }else{
            pinnedButton.setImage(UIImage(systemName: "star", withConfiguration: symbolConfig), for: .normal)
        }
        
        coinHandler.fetchChartData(id: coin.getID(), timeFrame: lineChartDataSets[selectedTimeFrameIndex].timeFrame)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        coinHandler.secondaryDelegate = self
    }
    
    func didUpdateCurrencyData() {}
        
    func didFailWithError(error: Error) {
        print(error)
    }
    
    @IBAction func addAlertPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToAlerts", sender: coin)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToAlerts"){
            let destVC = segue.destination as! AlertsVC
            destVC.coinHandler = coinHandler
            destVC.shouldGoStraighToAddAlertVC = true
            destVC.coinToAddAlertFor = coin
            
            
        }
    }
    
    @objc internal func refresh(sender: String){
        if (!coin.isInvalidated){
            priceLabel.text = K.convertToCoinPrice(coin.getPrice(), currency: coinHandler.preferredCurrency)
        }
        
    }
    
    @IBAction func pinnedButtonPressed(_ sender: Any) {
        if (coin.getPinned()){
            coin.setPinned(false)
            pinnedButton.setImage(UIImage(systemName: "star", withConfiguration: symbolConfig), for: .normal)
        }else{
            coin.setPinned(true)
            pinnedButton.setImage(UIImage(systemName: "star.fill", withConfiguration: symbolConfig), for: .normal)
        }
        coinHandler.sortCoins(sender: "pinned")
    }
}

//MARK: Line Chart
extension ContainerVC: CanUpdateLineChartData{
    @IBAction func lineChartTimeFrameChanged(_ sender: UISegmentedControl) {
        lineChart.noDataText = "Loading Data"
        selectedTimeFrameIndex = sender.selectedSegmentIndex
        if (lineChartDataSets[selectedTimeFrameIndex].data == nil){
            coinHandler.fetchChartData(id: coin.getID(), timeFrame: lineChartDataSets[selectedTimeFrameIndex].timeFrame)
        }
        updateLabels()
        lineChart.data = lineChartDataSets[selectedTimeFrameIndex].data
        self.lineChart.animate(xAxisDuration: 0.7)
        self.lineChart.resetViewPortOffsets()
        self.lineChart.resetZoom()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let formattedPrice = K.convertToCoinPrice(entry.y, currency: coinHandler.preferredCurrency)
        priceLabel.text = formattedPrice
        
        let format = DateFormatter()
        var dateFormat: String = "yyyy-MM-dd HH:mm:ss"
        if (selectedTimeFrameIndex == 0 || selectedTimeFrameIndex == 1 || selectedTimeFrameIndex == 2){
            dateFormat = "MMM-dd HH:mm"
        }
        else if (selectedTimeFrameIndex == 3 || selectedTimeFrameIndex == 4 || selectedTimeFrameIndex == 5 || selectedTimeFrameIndex == 6){
            dateFormat = "yyyy-MMM-dd"
        }
        format.dateFormat = dateFormat
        
        
        
        let date = NSDate(timeIntervalSince1970: Double(String(format: "%f", entry.x).prefix(10))!)

        h24ChangeLabel.text = format.string(from: date as Date)
        h24ChangeLabel.textColor = UIColor.label
    }
    
    
    
    func didUpdateLineChartDataSet(dataSet: LineChartDataSet, timeFrame: String) {
        DispatchQueue.main.async {
            var col = self.coin.getColor()
            if self.traitCollection.userInterfaceStyle == .dark {
                col = col.lighter() ?? UIColor.gray
            }else{
                col = col.darker() ?? UIColor.gray
            }
            dataSet.colors = [NSUIColor.init(cgColor: col.cgColor )]
            dataSet.drawCirclesEnabled = false
            dataSet.drawValuesEnabled = false
            dataSet.lineWidth = 1.5
            let gradientColors = [col.cgColor, UIColor.clear.cgColor] as CFArray
            let colorLocations:[CGFloat] = [0.0, 1.0]
            let gradient:CGGradient? = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
            if let grade = gradient{
                dataSet.fill = Fill.fillWithLinearGradient(grade, angle: 90.0)
                dataSet.drawFilledEnabled = true
            }
            
            dataSet.highlightColor = UIColor(cgColor: col.cgColor )
            dataSet.highlightLineWidth = 1
            
            
            let data = LineChartData(dataSet: dataSet)
            var change = (dataSet[dataSet.count - 1].y / dataSet[0].y) * 100
                        
            if (change < 0){
                change = 100 - change
            }else{
                change = change - 100
            }
            
            let high = dataSet.yMax
            let low = dataSet.yMin

            for i in 0..<self.lineChartDataSets.count{
                if self.lineChartDataSets[i].timeFrame == timeFrame{
                    self.lineChartDataSets[i].data = data
                    self.lineChartDataSets[i].change = change
                    self.lineChartDataSets[i].high = high
                    self.lineChartDataSets[i].low = low
                    if i == self.selectedTimeFrameIndex{
                        self.updateLabels()
                        self.lineChart.data = self.lineChartDataSets[self.selectedTimeFrameIndex].data
                        self.lineChart.animate(xAxisDuration: 0.7)
                    }
                }
            }
        }
    }
    
    private func initLineChart(){
        lineChart.fitScreen()
        lineChart.xAxis.enabled = false
        
        lineChart.drawBordersEnabled = true
        lineChart.borderLineWidth = 0.1
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.enabled = false
        lineChart.leftAxis.enabled = false
        lineChart.legend.enabled = false
        lineChart.noDataText = "Loading Data"
    }
    
    
    func panGestureEnded(_ chartView: ChartViewBase) {
        updateLabels()
        lineChart.highlightValue(nil)
    }
    
    func updateLabels(){
        var changeString = ""
        if (self.lineChartDataSets[self.selectedTimeFrameIndex].change > 0){
            h24ChangeLabel.textColor = UIColor.systemGreen
            changeString = "+\(String(format: "%.2f", self.lineChartDataSets[self.selectedTimeFrameIndex].change))%"
        }else{
            h24ChangeLabel.textColor = UIColor.systemRed
            changeString = "\(String(format: "%.2f", self.lineChartDataSets[self.selectedTimeFrameIndex].change))%"
        }
        priceLabel.text = K.convertToCoinPrice(coin.getPrice(), currency: coinHandler.preferredCurrency)
        self.h24ChangeLabel.text = "Change: \(changeString)"
        self.highLabel.text = "High: \(K.convertToCoinPrice(self.lineChartDataSets[self.selectedTimeFrameIndex].high, currency: self.coinHandler.preferredCurrency))"
        self.lowLabel.text = "Low: \(K.convertToCoinPrice(self.lineChartDataSets[self.selectedTimeFrameIndex].low, currency: self.coinHandler.preferredCurrency))"
        
    }
    
    func didFetchCoinPrice(price: Double) {}

    
 
}
