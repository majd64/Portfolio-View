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
    var coin: Coin!
    var coinHandler: CoinHandler!
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceValueLabel: UILabel!
    @IBOutlet weak var h24ChangeLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pinnedButton: UIButton!
    
    private var selectedTimeFrameIndex = 0
    var homeScreen: ViewController!
    
    let generator = UIImpactFeedbackGenerator(style: .light)
                
    
    private var lineChartDataSets: [(timeFrame: String, data: LineChartData?, change: String)] = [
        (timeFrame: "1D", data: nil, change: ""),
        (timeFrame: "1W", data: nil, change: ""),
        (timeFrame: "1M", data: nil, change: ""),
        (timeFrame: "3M", data: nil, change: ""),
        (timeFrame: "6M", data: nil, change: ""),
        (timeFrame: "1Y", data: nil, change: ""),
        (timeFrame: "MAX", data: nil, change: "")]
    
    private let symbolConfig = UIImage.SymbolConfiguration(scale: .large)
        
    override func viewDidLoad() {
        lineChartDataSets = [
            (timeFrame: "1D", data: nil, change: ""),
            (timeFrame: "1W", data: nil, change: ""),
            (timeFrame: "1M", data: nil, change: ""),
            (timeFrame: "3M", data: nil, change: ""),
            (timeFrame: "6M", data: nil, change: ""),
            (timeFrame: "1Y", data: nil, change: ""),
            (timeFrame: "MAX", data: nil, change: "")]
        refresh()
        coinHandler.delegate = self
        coinHandler.lineChartDelegate = self
        lineChart.delegate = self
        segmentedControl.selectedSegmentIndex = 0
        initLineChart()
        iconImage.image = coin.getImage()
        symbolLabel.text = coin.getSymbol().uppercased()
        
        if (coin.getPinned()){
            pinnedButton.setImage(UIImage(systemName: "star.fill", withConfiguration: symbolConfig), for: .normal)
        }else{
            pinnedButton.setImage(UIImage(systemName: "star", withConfiguration: symbolConfig), for: .normal)
        }
        
        for i in 0..<lineChartDataSets.count{
            coinHandler.fetchChartData(id: coin.getID(), timeFrame: lineChartDataSets[i].timeFrame)
        }
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        coinHandler.delegate = self
    }
    
    func didUpdateCoinsData() {
        refresh()
    }
    
    func didUpdateCurrencyData() {}
        
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
    @objc internal func refresh(){
        priceLabel.text = K.convertToCoinPrice(coin.getPrice(), currency: coinHandler.preferredCurrency)
    }
    
    @IBAction func pinnedButtonPressed(_ sender: Any) {
        if (coin.getPinned()){
            coin.setPinned(false)
            pinnedButton.setImage(UIImage(systemName: "star", withConfiguration: symbolConfig), for: .normal)
        }else{
            coin.setPinned(true)
            pinnedButton.setImage(UIImage(systemName: "star.fill", withConfiguration: symbolConfig), for: .normal)
        }
        coinHandler.sortCoins()
    }
}

//MARK: Line Chart
extension ContainerVC: CanUpdateLineChartData{
    @IBAction func lineChartTimeFrameChanged(_ sender: UISegmentedControl) {
       
        lineChart.noDataText = "Loading Data"
        
        
        selectedTimeFrameIndex = sender.selectedSegmentIndex
        h24ChangeLabel.text = lineChartDataSets[selectedTimeFrameIndex].change
        lineChart.data = lineChartDataSets[selectedTimeFrameIndex].data
        self.lineChart.animate(xAxisDuration: 0.6)
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
        h24ChangeLabel.text = format.string(from: NSDate(timeIntervalSince1970: Double(String(entry.x).prefix(10))!) as Date)
        generator.impactOccurred()
    }
    
    
    
    func didUpdateLineChartDataSet(dataSet: LineChartDataSet, timeFrame: String) {
        DispatchQueue.main.async {
            let col:CGColor
            
            if self.traitCollection.userInterfaceStyle == .dark {
                col = self.coin.getImage()?.averageColor?.lighter()?.cgColor ?? UIColor.gray.cgColor
            }else{
                col = self.coin.getImage()?.averageColor?.darker()?.cgColor ?? UIColor.gray.cgColor
            }
            dataSet.colors = [NSUIColor.init(cgColor: col)]
            dataSet.drawCirclesEnabled = false
            dataSet.drawValuesEnabled = false
            dataSet.lineWidth = 1.5
            let gradientColors = [col, UIColor.clear.cgColor] as CFArray
            let colorLocations:[CGFloat] = [1.0, 0]
            let gradient:CGGradient? = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
            if let grade = gradient{
                dataSet.fill = Fill.fillWithLinearGradient(grade, angle: 90.0)
                dataSet.drawFilledEnabled = true
            }
            
            dataSet.highlightColor = UIColor(cgColor: col)
            dataSet.highlightLineWidth = 1
            
            
            let data = LineChartData(dataSet: dataSet)
            print("\(timeFrame) \(dataSet[dataSet.count - 1].y)")
            print("\(timeFrame) \(dataSet[0].y)")
            var change = (dataSet[dataSet.count - 1].y / dataSet[0].y) * 100
            
            var changeString = ""
            
            if (change < 0){
                change = 100 - change
            }else{
                change = change - 100
            }
            
            if (change > 0){
                changeString = "+\(String(format: "%.2f", change))%"
            }else{
                
                changeString = "\(String(format: "%.2f", change))%"
            }
            
            
            
            
            for i in 0..<self.lineChartDataSets.count{
                if self.lineChartDataSets[i].timeFrame == timeFrame{
                    self.lineChartDataSets[i].data = data
                    self.lineChartDataSets[i].change = changeString
                  
                    if i == self.selectedTimeFrameIndex{
                        self.h24ChangeLabel.text = self.lineChartDataSets[self.selectedTimeFrameIndex].change
                        self.lineChart.data = self.lineChartDataSets[self.selectedTimeFrameIndex].data
                        self.lineChart.animate(xAxisDuration: 0.6)
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
        priceLabel.text = K.convertToCoinPrice(coin.getPrice(), currency: coinHandler.preferredCurrency)
        h24ChangeLabel.text = String(format: "%.2f", coin.getChangePercentage24h())
        lineChart.highlightValue(nil)
    }
    
    func didFetchCoinPrice(price: Double) {}
    
    
    
 
}
