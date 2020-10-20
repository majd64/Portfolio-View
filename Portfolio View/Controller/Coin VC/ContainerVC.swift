//
//  ContainerVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-07-11.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import Charts

class ContainerVC: UIViewController, CoinHandlerDelegate{
    var coin: Coin!
    var coinHandler: CoinHandler!
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceValueLabel: UILabel!
    @IBOutlet weak var h24ChangeLabel: UILabel!
    
    override func viewDidLoad() {
        coinHandler.lineChartDelegate = self
        initLineChart()
        coinHandler.lineChartTimeFrame = CoinHandler.lineChartTimeFrames[0]
        coinHandler.fetchLineChartData(for: coin.getID(), in: coin.getLineChartQuoteID(), exchange: coin.getLineChartExchange())
        iconImage.image = UIImage(named: coin.getID())
        symbolLabel.text = coin.getSymbol()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
    }
    
    func didUpdateCoinsData() {
        refresh()
    }
    
    func didUpdateExchangeRatesData() {}
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    @objc private func refresh(){
        priceLabel.text = coin.getPrice(withRate: coinHandler.getPreferredExchangeRate()?.getRateUsd() ?? 1, symbol: coinHandler.getPreferredExchangeRate()?.getCurrencySymbol() ?? "$")
        h24ChangeLabel.text = coin.getChangePercent24Hr()
    }
}

//MARK: Line Chart
extension ContainerVC: canUpdateLineChart{
    @IBAction func lineChartTimeFrameChanged(_ sender: UISegmentedControl) {
        lineChart.data = nil
        lineChart.noDataText = "Loading Data"
        coinHandler.lineChartTimeFrame = CoinHandler.lineChartTimeFrames[sender.selectedSegmentIndex]
        coinHandler.fetchLineChartData(for: coin.getID(), in: coin.getLineChartQuoteID(), exchange: coin.getLineChartExchange())
    }
    
    func didUpdateLineChartDataSet(dataSet: LineChartDataSet) {
        DispatchQueue.main.async { [self] in
            dataSet.colors = [NSUIColor.init(cgColor: UIImage(named: self.coin.getID())?.averageColor?.cgColor ?? UIColor.black.cgColor)]
            dataSet.drawCirclesEnabled = false
            dataSet.drawValuesEnabled = false
            dataSet.lineWidth = 1.5
            let gradientColors = [UIImage(named: self.coin.getID())?.averageColor?.cgColor, UIColor.clear.cgColor] as CFArray
            let colorLocations:[CGFloat] = [1.0, 0.0]
            let gradient:CGGradient? = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
            if let grade = gradient{
                dataSet.fill = Fill.fillWithLinearGradient(grade, angle: 90.0)
                dataSet.drawFilledEnabled = true
            }
            let data = LineChartData(dataSet: dataSet)
            self.lineChart.data = data
            self.lineChart.animate(xAxisDuration: 0.8)
        }
    }
    
    private func initLineChart(){
        lineChart.fitScreen()
        lineChart.xAxis.enabled = false
        lineChart.drawBordersEnabled = true
        lineChart.borderLineWidth = 0.1
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.enabled = false
        lineChart.legend.enabled = false
        lineChart.noDataText = "Loading Data"
    }
    
    func noLineChartData() {
        lineChart.data = nil
        lineChart.noDataText = "No Data Available"
        lineChart.setNeedsDisplay()
    }
}
