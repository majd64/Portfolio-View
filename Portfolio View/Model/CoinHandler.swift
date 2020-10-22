//
//  CoinHandler.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-24.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation
import RealmSwift
import Charts

class CoinHandler{
    private let defaults = UserDefaults.standard
    private let realm = try! Realm()
    var delegate: CoinHandlerDelegate?
    var lineChartDelegate: canUpdateLineChart?
    private var networkHandler: NetworkHandler = NetworkHandler()
    public var lineChartTimeFrame: (pointTimeFrame: String, numOfPoints: Int) = lineChartTimeFrames[1]
    
    public static let lineChartTimeFrames = [(pointTimeFrame: "m1", numOfPoints: 240), (pointTimeFrame: "m5", numOfPoints: 288), (pointTimeFrame: "m30", numOfPoints: 336), (pointTimeFrame: "h2", numOfPoints: 360), (pointTimeFrame: "h8", numOfPoints: 270), (pointTimeFrame: "h12", numOfPoints: 360), (pointTimeFrame: "d1", numOfPoints: 365), (pointTimeFrame: "w1", numOfPoints: 0)]
    
    private var coins: Results<Coin>!
    private var coinsArray: [Coin]{
        get{
            return Array(coins)
        }
    }
    
    private var exchangeRates: Results<ExchangeRate>!
    private var exchangeRateArray: [ExchangeRate]{
        get{
            return Array(exchangeRates)
        }
    }
    
    private static let preferredExchangeRateKey: String = "preferredCurrency"
    private var preferredExchangeRateId: String{
        get{
            if let rate = defaults.string(forKey: CoinHandler.preferredExchangeRateKey){
                return rate
            }
            defaults.set("united-states-dollar", forKey: CoinHandler.preferredExchangeRateKey)
            return "united-states-dollar"
        }set{
            defaults.set(newValue, forKey: CoinHandler.preferredExchangeRateKey)
        }
    }
    private var preferredExchangeRate: ExchangeRate?{
        return getExchangeRate(id: preferredExchangeRateId)
    }
    
    let sortTypeNames: [String] = ["Balance Value", "Market Cap", "24h Change", "Price", "Name"]
    let sortTypeIds: [String] = ["balanceValueUsd", "marketCapUsd", "changePercent24Hr", "priceUsd", "name"]
    private var preferredSortType: String{
        get{
            if let sortType = defaults.string(forKey: "preferredSortType"){
                return sortType
            }
            defaults.set("balanceValueUsd", forKey: "preferredSortType")
            return "balanceValueUsd"
        }set{
            if sortTypeIds.contains(newValue){
                defaults.set(newValue, forKey: "preferredSortType")
                sortCoins()
            }
        }
    }
    
    init() {
        networkHandler.delegate = self
        loadCoins()
        sortCoins()
        loadExchangeRates()
        fetchCoinData()
        fetchExchangeRateData()
    }
    
    private func loadCoins(){
        coins = realm.objects(Coin.self).sorted(byKeyPath: preferredSortType, ascending: true)
    }
    
    private func sortCoins(){
        coins = coins?.sorted(byKeyPath: "marketCapUsd", ascending: false)
        if (preferredSortType == "name"){
            coins = coins?.sorted(byKeyPath: preferredSortType, ascending: true)
            return
        }
        coins = coins?.sorted(byKeyPath: preferredSortType, ascending: false)
    }
    
    func getCoins() -> [Coin]{
        return coinsArray
    }
    
    private func getCoin(id: String) -> Coin?{
        for coin: Coin in coinsArray{
            if coin.getID() == id{
                return coin
            }
        }
        return nil
    }
    
    func setPreferredExchangeRateId(to currencyId: String){
        preferredExchangeRateId = currencyId
    }
    
    func setPreferredSortTypeId(to type: String){
        preferredSortType = type
    }
    
    private func loadExchangeRates(){
        exchangeRates = realm.objects(ExchangeRate.self).sorted(byKeyPath: "symbol", ascending: true)
    }

    func getExchangeRates() -> [ExchangeRate]{
        return exchangeRateArray
    }
    
    private func getExchangeRate(id: String) -> ExchangeRate?{
        for rate: ExchangeRate in exchangeRateArray{
            if rate.getId() == id{
                return rate
            }
        }
        return nil
    }
    
    func getPreferredExchangeRate() -> ExchangeRate?{
        return preferredExchangeRate
    }
    
    func getTotalBalanceValue() -> Double?{
        var totalBalanceValue: Double = 0
        if let rate = preferredExchangeRate{
            for coin: Coin in coinsArray{
                totalBalanceValue += coin.getBalanceValue(withRate: rate.getRateUsd())
            }
            return totalBalanceValue
        }
        return nil
    }
    
    func getTotalBalanceValue() -> String?{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        if let balanceValue = (getTotalBalanceValue() as Double?){
            if balanceValue != 0{
                let formattedBalance = "\(preferredExchangeRate?.getCurrencySymbol() ?? "$")\(numberFormatter.string(from: NSNumber(value: balanceValue)) ?? "0")"
                return formattedBalance
            }
        }
        return nil
    }
    
    func getTotalBalanceValueInBTC() -> Double?{
        if let balanceValue = getTotalBalanceValue() as Double?{
            if balanceValue != 0{
                if let bitcoin = getCoin(id: "bitcoin"){
                    return balanceValue  / bitcoin.getPrice(withRate: preferredExchangeRate?.getRateUsd() ?? 1)
                }
            }
        }
        return nil
    }
    
    func getTotalBalanceValueInBTC() -> String?{
        if let bal = getTotalBalanceValueInBTC() as Double?{
            return "\(String(format: "%.5f", bal)) BTC"
        }
        return nil
    }
    
    func getPreferredSortTypeId() -> String{
        return preferredSortType
    }
    
    //MARK: - Pie Chart
    func getPieChartDataSet() -> PieChartDataSet{
        var pieChartEntries: [PieChartDataEntry] = [PieChartDataEntry]()
        var pieChartEntryColors: [UIColor] = [UIColor]()
        for coin: Coin in coins!.sorted(byKeyPath: "balanceValueUsd", ascending: false) {
            if coin.getBalanceValue(withRate: preferredExchangeRate?.getRateUsd() ?? 1) != 0{
                let entry: PieChartDataEntry = PieChartDataEntry(value: coin.getBalanceValue(withRate: preferredExchangeRate?.getRateUsd() ?? 1))
                pieChartEntries.append(entry)
                let col: UIColor = (UIImage(named: coin.getID())?.averageColor)?.withAlphaComponent(0.75) ?? UIColor.white
                pieChartEntryColors.append(col)
            }
        }
        let chartDataSet = PieChartDataSet(entries: pieChartEntries, label: nil)
        chartDataSet.colors = pieChartEntryColors
        return chartDataSet
    }
    
    private var isCandleDataInBTC: Bool = false
    private var fetchingLineChartDataForCoin: Coin? = nil
}


//MARK: - Network Handler
extension CoinHandler: NetworkHandlerDelegate{
    func fetchCoinData(){
        networkHandler.fetchCoinData()
    }
    
    func fetchExchangeRateData(){
        networkHandler.fetchExchangeRateData()
    }

    func fetchLineChartData(for baseID: String, in quoteID: String, exchange: String){
        fetchingLineChartDataForCoin = getCoin(id: baseID)
        if quoteID == "bitcoin"{
            isCandleDataInBTC = true
        }else{
            isCandleDataInBTC = false
        }
        networkHandler.fetchCandleData(exchange: exchange, interval: lineChartTimeFrame.pointTimeFrame, baseID: baseID, quoteID: quoteID)
    }
    
    func didUpdateCoinsData(_ networkHandler: NetworkHandler, coinsData: AllCoinsModel) {
        DispatchQueue.main.async {
            for coinData: CoinModel in coinsData.data{
                if let priceUsd = Double(coinData.priceUsd ?? "0"), let marketCapUsd = Double(coinData.marketCapUsd ?? "0"), let change24h = Double(coinData.changePercent24Hr ?? "0"){
                
                    var coin: Coin? = self.getCoin(id: coinData.id)
                    if coin == nil{
                        coin = Coin(id: coinData.id, symbol: coinData.symbol ?? "", name: coinData.name ?? "")
                        do{
                            try self.realm.write(){
                                self.realm.add(coin!)
                            }
                        }catch{
                            print("error saving context \(error)")
                        }
                    }
                    coin!.setPriceUsd(to: priceUsd)
                    coin!.setMarketCapUsd(to: marketCapUsd)
                    coin!.setChangePercent24Hr(to: change24h)
                }
            }
            self.sortCoins()
            self.delegate?.didUpdateCoinsData()
        }
    }
    
    func didUpdateExchangesRateData(_ networkHandler: NetworkHandler, exchangeRatesData: AllExchangeRatesModel) {
        DispatchQueue.main.async {
            for exchangeRateData: ExchangeRateModel in exchangeRatesData.data{
                if let rateUsd = Double(exchangeRateData.rateUsd ?? "0"){
                    var rate: ExchangeRate? = self.getExchangeRate(id: exchangeRateData.id)
                    if rate == nil{
                        rate = ExchangeRate(id: exchangeRateData.id, symbol: exchangeRateData.symbol ?? "", currencySymbol: exchangeRateData.currencySymbol ?? "")
                        do{
                            try self.realm.write(){
                                self.realm.add(rate!)
                            }
                        }catch{
                            print("error saving context \(error)")
                        }
                    }
                    rate!.setRateUsd(to: rateUsd)
                }
            }
            self.delegate?.didUpdateExchangeRatesData()
        }
    }
    
    func didUpdateCandleData(_ networkHandler: NetworkHandler, candlesData: AllCandlesModel) {
        DispatchQueue.main.async {
            var lineChartEntry = [ChartDataEntry]()
            
            if candlesData.data.count == 0{
                if let coin: Coin = self.fetchingLineChartDataForCoin{
                    if coin.didAdjustLineChartRequest(){
                        self.fetchLineChartData(for: coin.getID(), in: coin.getLineChartQuoteID(), exchange: coin.getLineChartExchange())
                    }else{
                        self.lineChartDelegate?.noLineChartData()
                    }
                }
            }
            else if candlesData.data.count - self.lineChartTimeFrame.numOfPoints < 0{
                self.lineChartDelegate?.noLineChartData()
            }
            else{
                for i in candlesData.data.count - self.lineChartTimeFrame.numOfPoints..<candlesData.data.count{
                    var candleDataOpenPrice: Double = Double(candlesData.data[i].open) ?? 0
                    if self.isCandleDataInBTC{
                        candleDataOpenPrice *= self.getCoin(id: "bitcoin")?.getPrice(withRate: 1) ?? 1
                    }
                    let value = ChartDataEntry(x: candlesData.data[i].period, y: candleDataOpenPrice)
                    lineChartEntry.append(value)
                }
                let line1 = LineChartDataSet(entries: lineChartEntry, label: "")
                self.lineChartDelegate?.didUpdateLineChartDataSet(dataSet: line1)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        delegate?.didFailWithError(error: error)
    }
}

protocol CoinHandlerDelegate {
    func didUpdateCoinsData()
    func didUpdateExchangeRatesData()
    func didFailWithError(error: Error)
}

protocol canUpdateLineChart{
    func didUpdateLineChartDataSet(dataSet: LineChartDataSet)
    func noLineChartData()
    func didFailWithError(error: Error)
}

