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
    var refreshDelegate: CanRefresh?
    var lineChartDelegate: CanUpdateLineChartData?
    private var networkHandler: NetworkHandler = NetworkHandler()
    
    let excludedCoins = ["wrapped-bitcoin"]

    private var coins: Results<Coin>!
    private var coinsArray: [Coin]{
        get{
            return Array(coins)
        }
    }
    
    private var Currencies: Results<Currency>!
    private var CurrenciesArray: [Currency]{
        get{
            return Array(Currencies)
        }
    }
    
    private var preferredCurrencyId: String{
        get{
            if let rate = defaults.string(forKey: "preferredCurrency"){
                return rate
            }
            defaults.set("united-states-dollar", forKey: "preferredCurrency")
            return "united-states-dollar"
        }set{
            defaults.set(newValue, forKey: "preferredCurrency")
            refreshDelegate?.refresh()
        }
    }
    private var preferredCurrency: Currency?{
        return getCurrency(id: preferredCurrencyId)
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
        loadCurrencies()
        fetchCoinData()
        fetchCurrencyData()
    }
    
    private func loadCoins(){
        coins = realm.objects(Coin.self).sorted(byKeyPath: preferredSortType, ascending: true)
    }
    
    func sortCoins(){
        coins = coins?.sorted(byKeyPath: "marketCapUsd", ascending: false)
        if (preferredSortType == "name"){
            coins = coins?.sorted(byKeyPath: preferredSortType, ascending: true)
            coins = coins?.sorted(byKeyPath: "isPinned", ascending: false)
            refreshDelegate?.refresh()
            return
        }
        coins = coins?.sorted(byKeyPath: preferredSortType, ascending: false)
        coins = coins?.sorted(byKeyPath: "isPinned", ascending: false)
        refreshDelegate?.refresh()
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
    
    func setPreferredCurrencyId(to currencyId: String){
        preferredCurrencyId = currencyId
    }
    
    func setPreferredSortTypeId(to type: String){
        preferredSortType = type
    }
    
    private func loadCurrencies(){
        Currencies = realm.objects(Currency.self).sorted(byKeyPath: "symbol", ascending: true)
    }

    func getCurrencies() -> [Currency]{
        return CurrenciesArray
    }
    
    func getCurrency(id: String) -> Currency?{
        for rate: Currency in CurrenciesArray{
            if rate.getId() == id{
                return rate
            }
        }
        return nil
    }
    
    func getPreferredCurrency() -> Currency?{
        return preferredCurrency
    }
    
    func getTotalBalanceValue() -> Double?{
        var totalBalanceValue: Double = 0
        if let rate = preferredCurrency{
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
                let formattedBalance = "\(preferredCurrency?.getCurrencySymbol() ?? "$")\(numberFormatter.string(from: NSNumber(value: balanceValue)) ?? "0")"
                return formattedBalance
            }
        }
        return nil
    }
    
    func getTotalBalanceValueInBTC() -> Double?{
        if let balanceValue = getTotalBalanceValue() as Double?{
            if balanceValue != 0{
                if let bitcoin = getCoin(id: "bitcoin"){
                    return balanceValue  / bitcoin.getPrice(withRate: preferredCurrency?.getRateUsd() ?? 1)
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
            balanceValueChange24h += previousTransactionBalance * coin.getPrice(withRate: preferredCurrency?.getRateUsd() ?? 1) * (1 - (1/(1 + coin.getChangePercent24Hr()))) + newTransactionBalance * coin.getPrice(withRate: preferredCurrency?.getRateUsd() ?? 1)
        }
        return balanceValueChange24h
    }
    
    func refresh(){
        refreshDelegate?.refresh()
    }
    
    func getPortfolioPercentages() -> [(coinID: String, percentage: Double)]{
        var percentages: [(coinID: String, percentage: Double)] = []
        
        for coin in coinsArray{
            if coin.getBalance() != 0{
                if let totalValue: Double = getTotalBalanceValue(){
                    if totalValue != 0{
                        let percentage = (coin.getBalanceValue(withRate: preferredCurrency?.getRateUsd() ?? 1) / totalValue) * 100
                        
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
            if coin.getBalanceValue(withRate: preferredCurrency?.getRateUsd() ?? 1) != 0{
                let entry: PieChartDataEntry = PieChartDataEntry(value: coin.getBalanceValue(withRate: preferredCurrency?.getRateUsd() ?? 1))
                pieChartEntries.append(entry)
                let col: UIColor = (UIImage(named: coin.getID())?.averageColor)?.withAlphaComponent(1) ?? UIColor.white
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
    
    func fetchCurrencyData(){
        networkHandler.fetchCurrencyData()
    }

    func fetchLineChartData(for coin: Coin, timeFrame: String){
        fetchingLineChartDataForCoin = coin
        
        networkHandler.fetchCandleData(exchange: coin.getLineChartExchange(timeFrame: timeFrame), interval: coin.getPointTimeFrame(timeFrame: timeFrame), baseID: coin.getID(), quoteID: coin.getLineChartQuoteID(timeFrame: timeFrame), timeFrame: timeFrame)
    }
    

    
    func didUpdateCoinsData(_ networkHandler: NetworkHandler, coinsData: AllCoinsModel) {
        DispatchQueue.main.async {
            for coinData: CoinModel in coinsData.data{
                if !self.excludedCoins.contains(coinData.id){
                    if let priceUsd = Double(coinData.priceUsd ?? "0"), let marketCapUsd = Double(coinData.marketCapUsd ?? "0"), let change24h = Double(coinData.changePercent24Hr ?? "0"){
                    
                        var coin: Coin? = self.getCoin(id: coinData.id)
                        if coin == nil {
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
            }
            self.sortCoins()
            self.delegate?.didUpdateCoinsData()
        }
    }
    
    func didUpdateCurrencyData(_ networkHandler: NetworkHandler, CurrenciesData: AllCurrenciesModel) {
        DispatchQueue.main.async {
            for CurrencyData: CurrencyModel in CurrenciesData.data{
                if let rateUsd = Double(CurrencyData.rateUsd ?? "0"){
                    var rate: Currency? = self.getCurrency(id: CurrencyData.id)
                    if rate == nil{
                        rate = Currency(id: CurrencyData.id, symbol: CurrencyData.symbol ?? "", currencySymbol: CurrencyData.currencySymbol ?? "")
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
            self.delegate?.didUpdateCurrencyData()
        }
    }
    
    func didUpdateCandleData(_ networkHandler: NetworkHandler, candlesData: AllCandlesModel, timeFrame: String){
        DispatchQueue.main.async {
            if let coin: Coin = self.fetchingLineChartDataForCoin{
                var lineChartEntry = [ChartDataEntry]()
                let start = candlesData.data.count - coin.getNumOfPoints(timeFrame: timeFrame)
                let end = candlesData.data.count
                if end == 0{
                    if coin.requestDidFailShouldTryAgain(timeFrame: timeFrame, wasEmpty: true){
                        self.fetchLineChartData(for: coin, timeFrame: timeFrame)
                    }else{
                        self.lineChartDelegate?.noLineChartData(timeFrame: timeFrame)
                    }
                }
                else if start < 0{
                    if coin.requestDidFailShouldTryAgain(timeFrame: timeFrame, wasEmpty: true){
                        self.fetchLineChartData(for: coin, timeFrame: timeFrame)
                    }else{
                        self.lineChartDelegate?.noLineChartData(timeFrame: timeFrame)
                    }
                }else{
                    var inBTC = false
                    if coin.getLineChartQuoteID(timeFrame: timeFrame) == "bitcoin"{
                        inBTC = true
                    }
                    for i in start..<end{
                        let candleDataOpenPrice: Double = Double(candlesData.data[i].open) ?? 0]
                        
                        let value = ChartDataEntry(x: candlesData.data[i].period, y: candleDataOpenPrice)
                        lineChartEntry.append(value)
                    }
                    let line1 = LineChartDataSet(entries: lineChartEntry, label: "")
                    self.lineChartDelegate?.didUpdateLineChartDataSet(dataSet: line1, timeFrame: timeFrame, inBTC: inBTC)
                }
            }
        }
    }
    
    func didFailWithError(error: Error) {
        delegate?.didFailWithError(error: error)
    }
}

protocol CoinHandlerDelegate {
    func didUpdateCoinsData()
    func didUpdateCurrencyData()
    func didFailWithError(error: Error)
}

protocol CanRefresh {
    func refresh()
}

protocol CanUpdateLineChartData{
    func didUpdateLineChartDataSet(dataSet: LineChartDataSet, timeFrame: String, inBTC: Bool)
    func noLineChartData(timeFrame: String)
    func didFailWithError(error: Error)
}

