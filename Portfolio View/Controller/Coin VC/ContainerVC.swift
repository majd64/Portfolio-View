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
    
    private var selectedTimeFrameIndex = 1
    var homeScreen: ViewController!
    
    let generator = UIImpactFeedbackGenerator(style: .light)
                
    
    private var lineChartDataSets: [(timeFrame: String, data: LineChartData?, didFail: Bool, inBTC: Bool)] = [
        (timeFrame: "4H", data: nil, didFail: false, inBTC: false),
        (timeFrame: "1D", data: nil, didFail: false, inBTC: false),
        (timeFrame: "1W", data: nil, didFail: false, inBTC: false),
        (timeFrame: "1M", data: nil, didFail: false, inBTC: false),
        (timeFrame: "3M", data: nil, didFail: false, inBTC: false),
        (timeFrame: "6M", data: nil, didFail: false, inBTC: false),
        (timeFrame: "1Y", data: nil, didFail: false, inBTC: false)]
    
    private let symbolConfig = UIImage.SymbolConfiguration(scale: .large)
        
    override func viewDidLoad() {
        lineChartDataSets = [
            (timeFrame: "4H", data: nil, didFail: false, inBTC: false),
            (timeFrame: "1D", data: nil, didFail: false, inBTC: false),
            (timeFrame: "1W", data: nil, didFail: false, inBTC: false),
            (timeFrame: "1M", data: nil, didFail: false, inBTC: false),
            (timeFrame: "3M", data: nil, didFail: false, inBTC: false),
            (timeFrame: "6M", data: nil, didFail: false, inBTC: false),
            (timeFrame: "1Y", data: nil, didFail: false, inBTC: false)]
        refresh()
        coinHandler.delegate = self
        coinHandler.lineChartDelegate = self
        lineChart.delegate = self
        segmentedControl.selectedSegmentIndex = 1
        initLineChart()
        iconImage.image = UIImage(named: coin.getID())
        symbolLabel.text = coin.getSymbol()
        
        if (coin.getPinned()){
            pinnedButton.setImage(UIImage(systemName: "star.fill", withConfiguration: symbolConfig), for: .normal)
        }else{
            pinnedButton.setImage(UIImage(systemName: "star", withConfiguration: symbolConfig), for: .normal)
        }
        
        coinHandler.fetchLineChartData(for: coin, timeFrame: lineChartDataSets[1].timeFrame)
        for i in 0..<lineChartDataSets.count{
            if i != 1{
                coinHandler.fetchLineChartData(for: coin, timeFrame: lineChartDataSets[i].timeFrame)
            }
        }
        super.viewDidLoad()
    }
    
    func didUpdateCoinsData() {
        refresh()
    }
    
    func didUpdateCurrencyData() {}
        
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
    @objc internal func refresh(){
        priceLabel.text = coin.getPrice(withRate: coinHandler.getPreferredCurrency()?.getRateUsd() ?? 1, symbol: coinHandler.getPreferredCurrency()?.getCurrencySymbol() ?? "$")
        h24ChangeLabel.text = coin.getChangePercent24Hr()
    }
    
    @IBAction func pinnedButtonPressed(_ sender: Any) {
        if (coin.getPinned()){
            coin.setPinned(to: false)
            pinnedButton.setImage(UIImage(systemName: "star", withConfiguration: symbolConfig), for: .normal)
        }else{
            coin.setPinned(to: true)
            pinnedButton.setImage(UIImage(systemName: "star.fill", withConfiguration: symbolConfig), for: .normal)
        }
        coinHandler.sortCoins()
    }
}

//MARK: Line Chart
extension ContainerVC: CanUpdateLineChartData{
    @IBAction func lineChartTimeFrameChanged(_ sender: UISegmentedControl) {
        if (lineChartDataSets[sender.selectedSegmentIndex].didFail){
            lineChart.noDataText = "No Data Available"
        }else{
            lineChart.noDataText = "Loading Data"
        }
        selectedTimeFrameIndex = sender.selectedSegmentIndex
        lineChart.data = lineChartDataSets[selectedTimeFrameIndex].data
        self.lineChart.animate(xAxisDuration: 0.6)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if entry.y < 1{
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 6
            numberFormatter.minimumSignificantDigits = 3
            numberFormatter.maximumSignificantDigits = 3
            numberFormatter.roundingMode = .halfUp
        }else{
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
        }
        if (lineChartDataSets[selectedTimeFrameIndex].inBTC){
            let formattedPrice = "\(numberFormatter.string(from: NSNumber(value: entry.y)) ?? "0.00") BTC"
        }else{
            let formattedPrice = "$\(numberFormatter.string(from: NSNumber(value: entry.y)) ?? "0.00") USD"
        }
        
        
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

        
        priceLabel.text = formattedPrice
        generator.impactOccurred()
    }
    
    
    
    func didUpdateLineChartDataSet(dataSet: LineChartDataSet, timeFrame: String, inBTC: Bool) {
        DispatchQueue.main.async { [self] in
            let col:CGColor
            if self.traitCollection.userInterfaceStyle == .dark {
                col = UIImage(named: self.coin.getID())?.averageColor?.lighter()?.cgColor ?? UIColor.gray.cgColor
            }else{
                col = UIImage(named: self.coin.getID())?.averageColor?.darker()?.cgColor ?? UIColor.gray.cgColor
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
            
            for i in 0..<lineChartDataSets.count{
                if lineChartDataSets[i].timeFrame == timeFrame{
                    lineChartDataSets[i].data = data
                    if inBTC{
                        lineChartDataSets[selectedTimeFrameIndex].inBTC = true
                    }
                    if i == selectedTimeFrameIndex{
                        lineChart.data = lineChartDataSets[selectedTimeFrameIndex].data
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
        priceLabel.text = coin.getPrice(withRate: coinHandler.getPreferredCurrency()?.getRateUsd() ?? 1, symbol: coinHandler.getPreferredCurrency()?.getCurrencySymbol() ?? "$")
        h24ChangeLabel.text = coin.getChangePercent24Hr()
        lineChart.highlightValue(nil)
    }
    
    func noLineChartData(timeFrame: String) {
        for i in 0..<lineChartDataSets.count{
            if lineChartDataSets[i].timeFrame == timeFrame{
                lineChartDataSets[i].didFail = true
                if i == selectedTimeFrameIndex{
                    lineChart.noDataText = "No Data Available"
                    lineChart.data = lineChartDataSets[i].data
                    lineChart.setNeedsDisplay()
                    
                }
            }
        }
    }
}
