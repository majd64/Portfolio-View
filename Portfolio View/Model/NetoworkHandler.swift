//
//  NetworkHandler.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-25.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit


struct NetworkHandler{
    var delegate: NetworkHandlerDelegate?
    
    func fetchCoinData(currency: String, enabledCoinIds: String, numOfPages: Int){
        print("fetch coin data")
        for i in 1...numOfPages{
            let url: String = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(currency)&ids=\(enabledCoinIds)&order=market_cap_desc&per_page=\(250)&page=\(i)&sparkline=false&price_change_percentage=1h%2C24h%2C7d%2C30d%2C1y"
            performRequest(with: url, requestType: "coinData", otherInfo: nil)
        }
    }
    
    func fetchChartData(id: String, currency: String, days: String, timeFrame: String){
        let url: String = "https://api.coingecko.com/api/v3/coins/\(id)/market_chart?vs_currency=\(currency)&days=\(days)"
        performRequest(with: url, requestType: "chart", otherInfo: timeFrame)
    }
    
    func fetchExchangeRates(){
        let url = "https://api.coincap.io/v2/rates"
        performRequest(with: url, requestType: "rates", otherInfo: nil)
    }
    
    func fetchAvailbleCoins(numOfPages: Int){
        for i in 1...numOfPages{
            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(i * 150)) {
                let url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=\(250)&page=\(i)&sparkline=false"
                performRequest(with: url, requestType: "availbleCoins", otherInfo: String(i))
            }
        }
    }
        
    func performRequest(with urlString: String, requestType: String, otherInfo: String?){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if requestType == "coinData"{
                        if let coinsData: [CoinModel] = self.parseJSON(safeData){
                            self.delegate?.DidFetchCoinData(self, coinsData: coinsData)
                        }
                    }
                    else if requestType == "chart"{
                        if let candleData: ChartModel = self.parseJSON(safeData){
                            self.delegate?.didFetchChartData(self, candlesData: candleData, timeFrame: otherInfo ?? "")
                        }
                    }
                    else if requestType == "rates"{
                        if let rates: [ExchangeRate] = self.parseJSON(safeData){

                            self.delegate?.didFetchExchangeRates(self, rates: rates)
                        }
                    }
                    else if (requestType == "availbleCoins"){
                        if let coins: [AvailbleCoin] = self.parseJSON(safeData){
                            self.delegate?.didFetchAvailbleCoins(self, availbleCoins: coins, page: Int(otherInfo ?? ""))
                        }
                    }
                    
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> [CoinModel]?{
        let decoder = JSONDecoder()
        do{
            let coinsData = try decoder.decode([CoinModel].self, from: data)
            return coinsData
           
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSON(_ data: Data) -> ChartModel?{
        let decoder = JSONDecoder()
        do{
            let candlesData:ChartModel = try decoder.decode(ChartModel.self, from: data)
            return candlesData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSON(_ data: Data) -> [ExchangeRate]?{
        let decoder = JSONDecoder()
        do{
            let rates = try decoder.decode(ExchangeRateData.self, from: data)
            return rates.data
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSON(_ data: Data) -> [AvailbleCoin]?{
        let decoder = JSONDecoder()
        do{
            let coinsData = try decoder.decode([AvailbleCoin].self, from: data)
            return coinsData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

protocol NetworkHandlerDelegate{
    func DidFetchCoinData(_ networkHandler: NetworkHandler, coinsData: [CoinModel])
    func didFailWithError(error: Error)
    func didFetchChartData(_ networkHandler: NetworkHandler, candlesData: ChartModel, timeFrame: String)
    func didFetchExchangeRates(_ networkHandler: NetworkHandler, rates: [ExchangeRate])
    func didFetchAvailbleCoins(_ networkHandler: NetworkHandler, availbleCoins: [AvailbleCoin], page: Int?)
}
