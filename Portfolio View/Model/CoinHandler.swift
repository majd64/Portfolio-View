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

    public static let lineChartTimeFrames = [(timeFrame: "4H", pointTimeFrame: "m1", numOfPoints: 240), (timeFrame: "1D", pointTimeFrame: "m5", numOfPoints: 288), (timeFrame: "1W", pointTimeFrame: "m30", numOfPoints: 336), (timeFrame: "1M", pointTimeFrame: "h2", numOfPoints: 360), (timeFrame: "3M", pointTimeFrame: "h8", numOfPoints: 270), (timeFrame: "6M", pointTimeFrame: "h12", numOfPoints: 360), (timeFrame: "1Y", pointTimeFrame: "d1", numOfPoints: 365)]
    
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
    
    func sortCoins(){
        coins = coins?.sorted(byKeyPath: "marketCapUsd", ascending: false)
        if (preferredSortType == "name"){
            coins = coins?.sorted(byKeyPath: preferredSortType, ascending: true)
            coins = coins?.sorted(byKeyPath: "isPinned", ascending: false)
            return
        }
        coins = coins?.sorted(byKeyPath: preferredSortType, ascending: false)
        coins = coins?.sorted(byKeyPath: "isPinned", ascending: false)
    }
    
    func getCoins() -> [Coin]{
        return coinsArray
    }
    
    func getCoin(id: String) -> Coin?{
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
    
    func getExchangeRate(id: String) -> ExchangeRate?{
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
    
    func getPortfolioBalanceChange24h() -> Double?{
            var balanceValueChange24h: Double = 0
            
            for coin: Coin in coinsArray{
                var previousTransactionBalance: Double = 0
                var newTransactionBalance: Double = 0
                
                
                for transaction: Transaction in coin.getTransactions(){
                    
                    let type: String = transaction.getTransactionType()
                    if type == Transaction.typeSent || type == Transaction.typeSold || type == Transaction.typeTransferredFrom{
                        
                        if (NSDate().timeIntervalSince1970 - transaction.getDate() > 86400){
                            previousTransactionBalance -= transaction.getAmountOfParentCoin()
                        }else{
                            newTransactionBalance -= transaction.getAmountOfParentCoin()
                        }
                        
                    }
                    else if type == Transaction.typeReceived || type == Transaction.typeBought || type == Transaction.typeTransferredTo{
                        if (NSDate().timeIntervalSince1970 - transaction.getDate() > 86400){
                            previousTransactionBalance += transaction.getAmountOfParentCoin()
                        }else{
                            newTransactionBalance += transaction.getAmountOfParentCoin()
                        }
                    }
                }
                balanceValueChange24h += previousTransactionBalance * coin.getPrice(withRate: preferredExchangeRate?.getRateUsd() ?? 1) * (1 - (1/(1 + coin.getChangePercent24Hr()))) + newTransactionBalance * coin.getPrice(withRate: preferredExchangeRate?.getRateUsd() ?? 1)
                            
            }
            return balanceValueChange24h
        
        
    }
    
    func getPortfolioPercentages() -> [(coinID: String, percentage: Double)]{
        var percentages: [(coinID: String, percentage: Double)] = []
        
        for coin in coinsArray{
            if coin.getBalance() != 0{
                if let totalValue: Double = getTotalBalanceValue(){
                    if totalValue != 0{
                        let percentage = (coin.getBalanceValue(withRate: preferredExchangeRate?.getRateUsd() ?? 1) / totalValue) * 100
                        
                        percentages.append((coinID: coin.getID(), percentage: Double(String(format: "%.2f", percentage))!))
                    }
                }
            }
        }
        return percentages
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

    func fetchLineChartData(for coin: Coin, timeFrame: String){
        fetchingLineChartDataForCoin = coin
        let lineChartTimeFrame: (timeFrame: String, pointTimeFrame: String, numOfPoints: Int) = getLineChartTimeFrameData(timeFrame: timeFrame)!
        networkHandler.fetchCandleData(exchange: coin.getLineChartExchange(), interval: lineChartTimeFrame.pointTimeFrame, baseID: coin.getID(), quoteID: coin.getLineChartQuoteID(), timeFrame: lineChartTimeFrame.timeFrame)
    }
    
    func getLineChartTimeFrameData(timeFrame: String) -> (timeFrame: String, pointTimeFrame: String, numOfPoints: Int)?{
        for lineChartTimeFrame in CoinHandler.lineChartTimeFrames{
            if lineChartTimeFrame.timeFrame == timeFrame{
                return lineChartTimeFrame
            }
        }
        return nil
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
    
    func didUpdateCandleData(_ networkHandler: NetworkHandler, candlesData: AllCandlesModel, timeFrame: String) {
        DispatchQueue.main.async {
            var lineChartEntry = [ChartDataEntry]()
            let lineChartTimeFrame: (timeFrame: String, pointTimeFrame: String, numOfPoints: Int) = self.getLineChartTimeFrameData(timeFrame: timeFrame)!
            
            if candlesData.data.count == 0{
                if let coin: Coin = self.fetchingLineChartDataForCoin{
                    if coin.didAdjustLineChartRequest(){
                        self.fetchLineChartData(for: coin, timeFrame: timeFrame)
                    }else{
                        self.lineChartDelegate?.noLineChartData(timeFrame: timeFrame)
                    }
                }
            }
            else if candlesData.data.count - lineChartTimeFrame.numOfPoints < 0{
                self.lineChartDelegate?.noLineChartData(timeFrame: timeFrame)
            }
            else{
                for i in candlesData.data.count - lineChartTimeFrame.numOfPoints..<candlesData.data.count{
                    var candleDataOpenPrice: Double = Double(candlesData.data[i].open) ?? 0
                    if self.fetchingLineChartDataForCoin?.getLineChartQuoteID() == "bitcoin"{
                        candleDataOpenPrice *= self.getCoin(id: "bitcoin")?.getPrice(withRate: 1) ?? 1
                    }
                    let value = ChartDataEntry(x: candlesData.data[i].period, y: candleDataOpenPrice)
                    lineChartEntry.append(value)
                }
                let line1 = LineChartDataSet(entries: lineChartEntry, label: "")
                self.lineChartDelegate?.didUpdateLineChartDataSet(dataSet: line1, timeFrame: timeFrame)
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
    func didUpdateLineChartDataSet(dataSet: LineChartDataSet, timeFrame: String)
    func noLineChartData(timeFrame: String)
    func didFailWithError(error: Error)
}

