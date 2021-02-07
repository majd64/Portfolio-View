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
    let defaults = UserDefaults.standard
    private let realm = try! Realm(configuration: Realm.Configuration(schemaVersion: 2))
    var delegate: CoinHandlerDelegate?
    var secondaryDelegate: CoinHandlerDelegate?
    var lineChartDelegate: CanUpdateLineChartData?
    var networkHandler: NetworkHandler = NetworkHandler()
    private var coins: Results<Coin>!
    private var currencies: [String] = ["btc", "eth", "usd","aed","ars","aud","bdt","bhd","bmd","brl","cad","chf","clp","cny","czk","dkk","eur","gbp","hkd","huf","idr","ils","inr","jpy","krw","kwd","lkr","mmk","mxn","myr","ngn","nok","nzd","php","pkr","pln","rub","sar","sek","sgd","thb","try","twd","uah","vef","vnd","zar","xdr","xag","xau"]
    private var exchangeRates: [ExchangeRate] = []
    var availbleCoins: [AvailbleCoin] = []
    var tempraryCoins: [AvailbleCoin] = []
    static var globalRefreshDelegate: CoinHandlerDelegate?
    
    var defaultDarkCellColor = "#48466D"
    var defaultDarkCellColorAlpha = 0.85
    var defaultLightCellColor = "#DBE2EF"
    var defaultLightCellColorAlpha = 0.85
    
    var isUpdatingCoinIdsArray = false
    
    func updateEnabledCoinIdsArray(newArray: [String]){
        isUpdatingCoinIdsArray = true
        for i in newArray{
            if (enabledCoinIdsArray.firstIndex(of: i) == nil){
                var array = defaults.stringArray(forKey: "enabledCoins")!
                array.append(i.lowercased())
                defaults.setValue(array, forKey: "enabledCoins")
            }
        }
        
        for i in enabledCoinIdsArray{
            if (newArray.firstIndex(of: i) == nil){
                if let coin: Coin = getCoin(id: i){
                    if coin.getBalance() == 0{
                        var array = defaults.stringArray(forKey: "enabledCoins")!
                        if let index = array.firstIndex(of: i.lowercased()){
                            array.remove(at: index)
                            defaults.setValue(array, forKey: "enabledCoins")
                        }
                    }
                }
            }
        }
    }
    
    func deleteUnenabledCoins(){
        for coin: Coin in coins{
            if enabledCoinIdsArray.firstIndex(of: coin.getID()) == nil{
                do{
                    try self.realm.write(){
                        self.realm.delete(coin)
                    }
                }catch{
                    print("error saving context \(error)")
                }
            }
        }
        fetchCoinData(lightRefresh: false)
    }
    
    let sortTypeNames: [String] = ["Balance Value", "Market Cap", "24h Change", "Price", "Name"]
    let sortTypeIds: [String] = ["balanceValue", "marketCapRank", "changePercentage24h", "price", "name"]
    
    static func globalRefresh(){
        globalRefreshDelegate?.requestRefresh()
    }
    

    init() {
        networkHandler.delegate = self
        networkHandler.fetchExchangeRates()
        networkHandler.fetchAvailbleCoins(numOfPages: 12)
        coins = realm.objects(Coin.self)
        if defaults.string(forKey: "updateVersion") == "2"{
            migrateFromVersion2()
        }
        defaults.set("4", forKey: "updateVersion")
    }
    func migrateFromVersion2(){
        let numberOfCoinsWithBalance = getPortfolioPercentages().count
        var enabledCoins = enabledCoinIdsArray
        enabledCoins = []
        let totalNumberOfCoins = numberOfCoinsWithBalance < 25 ? 25 : numberOfCoinsWithBalance
        var counter = 0
        for coin: Coin in coins.sorted(byKeyPath: "marketCapRank", ascending: true).sorted(byKeyPath: "balanceValue", ascending: false){
            if counter < totalNumberOfCoins{
                enabledCoins.append(coin.getID())
                counter += 1
            }else{
                break
            }
        }
        defaults.setValue(enabledCoins, forKey: "enabledCoins")
        for coin: Coin in coins{
            if !enabledCoins.contains(coin.getID()){
                do{
                    try self.realm.write(){
                        self.realm.delete(coin)
                    }
                }catch{
                    print("error saving context \(error)")
                }
            }
        }
    }
    
    func shouldSpin() -> Bool{
        if coins.count != enabledCoinIdsArray.count{
            return true
        }
        return false
    }
    
    func sortCoins(sender: String){
        var ascending: Bool = false
        coins = coins?.sorted(byKeyPath: "marketCapRank", ascending: true)
        if self.preferredSortType == "name" || preferredSortType == "marketCapRank"{
            ascending = true
        }
        coins = coins?.sorted(byKeyPath: preferredSortType, ascending: ascending)
        coins = coins?.sorted(byKeyPath: "isPinned", ascending: false)
        refresh(sender: sender)
    }
    
    func getCoins() -> [Coin]{
        return Array(coins)
    }
    
    func getAvailbleCoins() -> [AvailbleCoin]{
        return availbleCoins
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

    func getTotalBalanceValue() -> Double{//ERROR HERE
        var totalBalanceValue: Double = 0
        
        for coin: Coin in coins{
            totalBalanceValue += coin.getBalanceValue()
        }
        return totalBalanceValue
    }
    
    func refresh(sender: String){
        secondaryDelegate?.refresh(sender: sender)
        delegate?.refresh(sender: sender)
    
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
    
    func generateQueryStringOfEnabledCoinIdsSeperatedByCommas(numberOfCoins: Int?) -> String{
        
        if let numOfCoins = numberOfCoins{
            let maxNumberOfCoins = coins.count < numOfCoins ? coins.count : numOfCoins
            var query = ""
            var counter = 0
            for coin: Coin in coins.sorted(byKeyPath: "marketCapRank", ascending: true).sorted(byKeyPath: "balanceValue", ascending: false){
                if counter < maxNumberOfCoins - 1{
                    query += coin.getID() + ","
                    counter += 1
                }else{
                    query += coin.getID()
                    break
                }
            }
            return query
        }else{
            var query = ""
            let arr = enabledCoinIdsArray
            for i in 0..<arr.count{
                if (i < arr.count - 1){
                    query += arr[i]
                    query += ","
                }else{
                    query += arr[i]
                }
            }
            return query
        }
        
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
        for i: ExchangeRate in exchangeRates{
            if i.symbol.uppercased() == from.uppercased(){
                for l: ExchangeRate in exchangeRates{
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
                    if type == Transaction.typeBought || type == Transaction.typeReceived{
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


//MARK: - Network Handler
extension CoinHandler: NetworkHandlerDelegate{
    func fetchCoinData(lightRefresh: Bool){//light refresh does absolutley nothing now
        let query = generateQueryStringOfEnabledCoinIdsSeperatedByCommas(numberOfCoins: nil)
        if (query != ""){
            let numOfPages: Int = Int((Double(enabledCoinIdsArray.count) / Double(40)).rounded(.up))
            networkHandler.fetchCoinData(currency: preferredCurrency, enabledCoinIds: query, numOfPages: lightRefresh ? 1 : numOfPages)
        }else{
            refresh(sender: "fetch coin data w/ no coins");
        }
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
    
    
    func didFetchAvailbleCoins(_ networkHandler: NetworkHandler, availbleCoins: [AvailbleCoin], page: Int?) {
        
        if let pageNum = page{
            if (pageNum == 1){
                self.availbleCoins = availbleCoins
                self.availbleCoins.append(contentsOf: tempraryCoins)
                tempraryCoins = []
            }else{
                if (self.availbleCoins.count == 0){
                    tempraryCoins.append(contentsOf: availbleCoins)
                    
                }else{
                    self.availbleCoins.append(contentsOf: availbleCoins)
                }
                
            }
        }
        
    }
    
    func didFetchExchangeRates(_ networkHandler: NetworkHandler, rates: [ExchangeRate]){
        exchangeRates = rates
        refresh(sender: "did fetch exchnage rates")
    }
    
    func DidFetchCoinData(_ networkHandler: NetworkHandler, coinsData: [CoinModel]) {
        DispatchQueue.main.async {
            for coinData: CoinModel in coinsData{
                var coin: Coin? = self.getCoin(id: coinData.id)
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
                let marketCap = coinData.market_cap_rank ?? 10000
                                
                coin!.update(price: coinData.current_price ?? 0, marketCapRank: (marketCap == 0) ? 10000 : marketCap, change24h: coinData.price_change_percentage_24h ?? 0, change1h: coinData.price_change_percentage_1h_in_currency ?? 0, change1w: coinData.price_change_percentage_7d_in_currency ?? 0, change1m: coinData.price_change_percentage_30d_in_currency ?? 0, change1y: coinData.price_change_percentage_1y_in_currency ?? 0)
            }
            self.defaults.setValue(true, forKey: "didInit")
            self.sortCoins(sender: "did fetch")
        }
    }
    
    func didFetchChartData(_ networkHandler: NetworkHandler, candlesData: ChartModel, timeFrame: String){
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
        secondaryDelegate?.didFailWithError(error: error)
        delegate?.didFailWithError(error: error)
    }
}

protocol CoinHandlerDelegate {
    func requestRefresh()
    func refresh(sender: String)
    func didFetchCoinPrice(price: Double)
    func didFailWithError(error: Error)
}

protocol CanUpdateLineChartData{
    func didUpdateLineChartDataSet(dataSet: LineChartDataSet, timeFrame: String)
    func didFailWithError(error: Error)
}


