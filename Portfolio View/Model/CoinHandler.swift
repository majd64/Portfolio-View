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
    private var coins: Results<Coin>!
    private var currencies: [String] = []
    
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
        networkHandler.delegate = self
        coins = realm.objects(Coin.self)
        sortCoins()
        fetchCoinData()
        networkHandler.fetchCurrencies()
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
                let col: UIColor = (UIImage(named: coin.getID())?.averageColor)?.withAlphaComponent(1) ?? UIColor.white
                pieChartEntryColors.append(col)
            }
        }
        let chartDataSet = PieChartDataSet(entries: pieChartEntries, label: nil)
        chartDataSet.colors = pieChartEntryColors
        return chartDataSet
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
    
    func fetchCoinPrice(coinID: String, currency: String){
        networkHandler.fetchCoinPrice(coinID: coinID, currency: currency)
    }
    
    func didFetchCoinPrice(networkHandler: NetworkHandler, price: Double) {
        delegate?.didFetchCoinPrice(price: price)
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
            for coinData: CoinModel in coinsData{
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
                coin!.setPrice(coinData.current_price ?? 0)
                coin!.setMarketCapRank(coinData.market_cap_rank ?? 0)
                coin!.setChangePercent24h(coinData.price_change_percentage_24h ?? 0)
            }
            self.sortCoins()
            self.delegate?.didUpdateCoinsData()
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


