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
    private let realm = try! Realm(configuration: Realm.Configuration(schemaVersion: 2))
    var delegate: CoinHandlerDelegate?
    var refreshDelegate: CanRefresh?
    var lineChartDelegate: CanUpdateLineChartData?
    private var networkHandler: NetworkHandler = NetworkHandler()
    private var coins: Results<Coin>!
    private var currencies: [String] = []
    private var exchangeRates: [ExchnageRate] = []
    
    var preferredCurrency: String{
        get{
            if let rate = defaults.string(forKey: "preferredCurrency"){
                return rate
            }
            defaults.set("usd", forKey: "preferredCurrency")
            return "usd"
        }set{
            defaults.set(newValue, forKey: "preferredCurrency")
            fetchCoinData()
        }
    }
    
    var secondaryCurrency: String{
        get{
            if let rate = defaults.string(forKey: "secondaryCurrency"){
                return rate
            }
            defaults.set("btc", forKey: "secondaryCurrency")
            return "usd"
        }set{
            defaults.set(newValue, forKey: "secondaryCurrency")
            fetchCoinData()
        }
    }
    
    var deviceToken: String{
        get{
            guard let token = defaults.string(forKey: "deviceToken") else{
                fatalError("no device token")
            }
            return token
        }
    }
    
    var appearance: String{
        get{
            if let appearance = defaults.string(forKey: "appearance"){
                return appearance
            }
            defaults.set("auto", forKey: "appearance")
            return "auto"
        }set{
            defaults.set(newValue, forKey: "appearance")
        }
    }
    
    var didInit: Bool{
        if coins.count != 0{
            return true
        }
        return false
    }
    
    let sortTypeNames: [String] = ["Balance Value", "Market Cap", "24h Change", "Price", "Name"]
    let sortTypeIds: [String] = ["balanceValue", "marketCapRank", "changePercentage24h", "price", "name"]
    var preferredSortType: String{
        get{
            if let sortType = defaults.string(forKey: "preferredSortType"){
                return sortType
            }
            defaults.set("balanceValue", forKey: "preferredSortType")
            return "balanceValue"
        }set{
            if sortTypeIds.contains(newValue){
                defaults.set(newValue, forKey: "preferredSortType")
                sortCoins()
            }
        }
    }
    
    init() {
        
        
        if defaults.string(forKey: "updateVersion") == nil{
            defaults.set("balanceValue", forKey: "preferredSortType")
            defaults.set("usd", forKey: "preferredCurrency")
            
        }
        defaults.set("2", forKey: "updateVersion")
        
        
        
        networkHandler.delegate = self
        coins = realm.objects(Coin.self)
        sortCoins()
        fetchCoinData()
        networkHandler.fetchCurrencies()
        networkHandler.fetchExchangeRates()
    }
    
    func sortCoins(){
        var ascending: Bool = false
        coins = coins?.sorted(byKeyPath: "marketCapRank", ascending: true)
        if preferredSortType == "name" || preferredSortType == "marketCapRank"{
            ascending = true
        }
        coins = coins?.sorted(byKeyPath: preferredSortType, ascending: ascending)
        coins = coins?.sorted(byKeyPath: "isPinned", ascending: false)
        refreshDelegate?.refresh()
    }
    
    func getCoins() -> [Coin]{
        return Array(coins)
    }
    
    func getCoin(id: String) -> Coin?{
        for coin: Coin in coins{
            if coin.getID() == id{
                return coin
            }
        }
        return nil
    }
    
    func getCurrencies() -> [String]{
        return currencies
    }

    func getTotalBalanceValue() -> Double{
        var totalBalanceValue: Double = 0
        for coin: Coin in coins{
            totalBalanceValue += coin.getBalanceValue()
        }
        return totalBalanceValue
    }
    
    func refresh(){
        refreshDelegate?.refresh()
    }

    func getPortfolioPercentages() -> [(coinID: String, percentage: Double)]{
        var percentages: [(coinID: String, percentage: Double)] = []
        
        for coin in coins.sorted(byKeyPath: "balanceValue", ascending: false){
            if coin.getBalance() != 0{
                if getTotalBalanceValue() != 0{
                    let percentage = (coin.getBalanceValue() / getTotalBalanceValue()) * 100
                    percentages.append((coinID: coin.getID(), percentage: Double(String(format: "%.2f", percentage))!))
                }
            }
        }
        return percentages
    }
    
    //MARK: - Pie Chart
    func getPieChartDataSet() -> PieChartDataSet{
        var pieChartEntries: [PieChartDataEntry] = [PieChartDataEntry]()
        var pieChartEntryColors: [UIColor] = [UIColor]()
        for coin: Coin in coins!.sorted(byKeyPath: "balanceValue", ascending: false) {
            if coin.getBalanceValue() != 0{
                let entry: PieChartDataEntry = PieChartDataEntry(value: coin.getBalanceValue())
                pieChartEntries.append(entry)
                let col = coin.getColor()
                pieChartEntryColors.append(col)
            }
        }
        let chartDataSet = PieChartDataSet(entries: pieChartEntries, label: nil)
        chartDataSet.colors = pieChartEntryColors
        return chartDataSet
    }
    
    func convertCurrencies(from: String, to: String, amount: Double) -> Double?{
        for i: ExchnageRate in exchangeRates{
            if i.symbol.uppercased() == from.uppercased(){
                for l: ExchnageRate in exchangeRates{
                    if l.symbol.uppercased() == to.uppercased(){
                        let fromPrice = Double(i.rateUsd) ?? 1
                        let toPrice = Double(l.rateUsd) ?? 1
                  
                        return fromPrice/toPrice*amount
                    }
                }
            }
        }
        return nil
    }
}


//MARK: - Network Handler
extension CoinHandler: NetworkHandlerDelegate{
    func fetchCoinData(){
        networkHandler.fetchCoinData(currency: preferredCurrency)
    }
    
    func didFetchCurrencies(_ networkHandler: NetworkHandler, currencies: [String]) {
        self.currencies = currencies
    }
    
    func didFetchExchangeRates(_ networkHandler: NetworkHandler, rates: [ExchnageRate]){
        exchangeRates = rates
    }
    
    
    func fetchChartData(id: String, timeFrame: String){
        var days = ""
        switch timeFrame{
        case "4H":
            days = "0.16"
        case "1D":
            days = "1"
        case "1W":
            days = "7"
        case "1M":
            days = "30"
        case "3M":
            days = "90"
        case "6M":
            days = "180"
        case "1Y":
            days = "365"
        case "max":
            days = "max"
        default:
            days = "max"
        }
        networkHandler.fetchChartData(id: id, currency: preferredCurrency, days: days, timeFrame: timeFrame)
    }
    
    func didUpdateCoinsData(_ networkHandler: NetworkHandler, coinsData: [CoinModel]) {
        DispatchQueue.main.async {
            var didMigrate = false
            for coinData: CoinModel in coinsData{
                var coin: Coin? = self.getCoin(id: coinData.id)
                if self.defaults.string(forKey: "didMigrateFromVersion1") == nil{
                    didMigrate = true
                    let newCoin = Coin(id: coinData.id, symbol: coinData.symbol ?? "", name: coinData.name ?? "", image: coinData.image ?? "")
                    do{
                        try self.realm.write(){
                            self.realm.add(newCoin)
                        }
                    }catch{
                        print("error saving context \(error)")
                    }
                    newCoin.setCoinVersion(2)
                    newCoin.setPrice(coinData.current_price ?? 0)
                    newCoin.setMarketCapRank(coinData.market_cap_rank ?? 0)
                    newCoin.setChangePercent24h(coinData.price_change_percentage_24h ?? 0)
                    
                    newCoin.setChangePercent1h(coinData.price_change_percentage_1h_in_currency ?? 0)
                    newCoin.setChangePercent1w(coinData.price_change_percentage_7d_in_currency ?? 0)
                    newCoin.setChangePercent1m(coinData.price_change_percentage_30d_in_currency ?? 0)
                    newCoin.setChangePercent1y(coinData.price_change_percentage_1y_in_currency ?? 0)
                        
                    if let transactions = coin?.getTransactions(){
                        for transaction in transactions{
                            newCoin.addTransaction(transaction)
                        }
                    }
                    
                    if coin != nil{
                        do{
                            try self.realm.write(){
                                self.realm.delete(coin!)
                            }
                        }catch{
                            print("error saving context \(error)")
                        }
                    }
                }else{
                    if coin == nil {
                        coin = Coin(id: coinData.id, symbol: coinData.symbol ?? "", name: coinData.name ?? "", image: coinData.image ?? "")
                        do{
                            try self.realm.write(){
                                self.realm.add(coin!)
                            }
                        }catch{
                            print("error saving context \(error)")
                        }
                    }
                coin!.setPrice(coinData.current_price ?? 0)
                coin!.setMarketCapRank(coinData.market_cap_rank ?? 0)
                coin!.setChangePercent24h(coinData.price_change_percentage_24h ?? 0)
                    
                coin!.setChangePercent1h(coinData.price_change_percentage_1h_in_currency ?? 0)
                coin!.setChangePercent1w(coinData.price_change_percentage_7d_in_currency ?? 0)
                coin!.setChangePercent1m(coinData.price_change_percentage_30d_in_currency ?? 0)
                coin!.setChangePercent1y(coinData.price_change_percentage_1y_in_currency ?? 0)
                }
            }
            self.sortCoins()
            self.delegate?.didUpdateCoinsData()
            if didMigrate{
                for c: Coin in self.getCoins(){
                    if c.getCoinVersion() != 2{
                        do{
                            try self.realm.write(){
                                self.realm.delete(c)
                            }
                        }catch{
                            print("error saving context \(error)")
                        }
                    }
                }
                self.defaults.setValue(true, forKey: "didMigrateFromVersion1")
            }
        }
    }
    
    func didUpdateChartData(_ networkHandler: NetworkHandler, candlesData: ChartModel, timeFrame: String){
        DispatchQueue.main.async {
            var lineChartEntry = [ChartDataEntry]()
            for i in candlesData.prices{
                let value = ChartDataEntry(x: Double(i[0]), y: Double(i[1]) )
                lineChartEntry.append(value)
            }
            let line1 = LineChartDataSet(entries: lineChartEntry, label: "")
            self.lineChartDelegate?.didUpdateLineChartDataSet(dataSet: line1, timeFrame: timeFrame)
        }
    }
    
    func didFailWithError(error: Error) {
        delegate?.didFailWithError(error: error)
    }
    
    
    
    
    func getPortfolioPriceChange() -> [Double]{
        var changes: [Double] = [0, 0, 0, 0, 0]
        for i in 0...4{
            var seconds: Double = 0
            var change: Double = 0
            
            var totalChange: Double = 0
            for coin: Coin in coins{
                switch i{
                case 0:
                    seconds = 3600
                    change = coin.getChangePercentage1h()
                case 1:
                    seconds = 86400
                    change = coin.getChangePercentage24h()
                case 2:
                    seconds = 604800
                    change = coin.getChangePercentage1w()
                case 3:
                    seconds = 2592000
                    change = coin.getChangePercentage1m()
                case 4:
                    seconds = 31536000
                    change = coin.getChangePercentage1y()
                default:
                    seconds = 3600
                    change = coin.getChangePercentage1h()
                }
                
                for transaction: Transaction in coin.getTransactions(){
                    let type = transaction.getTransactionType()
                    if type == Transaction.typeBought || type == Transaction.typeReceived || type == Transaction.typeTransferredTo{
                        if (NSDate().timeIntervalSince1970 - transaction.getDate()) < seconds{//transaction added today
                            totalChange += (transaction.getAmountOfParentCoin() * coin.getPrice())
                        }else{
                            let startPrice = coin.getPrice() / ((change/100) + 1)
                            let coinPriceChange = coin.getPrice() - startPrice
                            let transactionPriceChange = coinPriceChange * transaction.getAmountOfParentCoin()
                            totalChange += transactionPriceChange
                        }
                    }else{
                        if (NSDate().timeIntervalSince1970 - transaction.getDate()) < seconds{//transaction added today
                            totalChange -= (transaction.getAmountOfParentCoin() * coin.getPrice())
                        }
                    }
                }
            }
            changes[i] = totalChange
            
        }
        return changes
        
    }
    
 
    
}

protocol CoinHandlerDelegate {
    func didUpdateCoinsData()
    func didFetchCoinPrice(price: Double)
    func didFailWithError(error: Error)
}

protocol CanRefresh {
    func refresh()
}

protocol CanUpdateLineChartData{
    func didUpdateLineChartDataSet(dataSet: LineChartDataSet, timeFrame: String)
    func didFailWithError(error: Error)
}


