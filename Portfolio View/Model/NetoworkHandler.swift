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
    
    func fetchCoinData(currency: String){
        let url: String = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(currency)&order=market_cap_desc&per_page=160&page=1&sparkline=false&price_change_percentage=1h%2C24h%2C7d%2C14d%2C30d%2C200d%2C1y"
        performRequest(with: url, requestType: "coinData", otherInfo: nil)
    }
    
    func fetchChartData(id: String, currency: String, days: String, timeFrame: String){
        let url: String = "https://api.coingecko.com/api/v3/coins/\(id)/market_chart?vs_currency=\(currency)&days=\(days)"
        performRequest(with: url, requestType: "chart", otherInfo: timeFrame)
    }
    
    func fetchCurrencies(){
        let url: String = "https://api.coingecko.com/api/v3/simple/supported_vs_currencies"
        performRequest(with: url, requestType: "currencies", otherInfo: nil)
    }
    
    func fetchExchangeRates(){
        let url = "https://api.coincap.io/v2/rates"
        performRequest(with: url, requestType: "rates", otherInfo: nil)
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
                            self.delegate?.didUpdateCoinsData(self, coinsData: coinsData)
                        }
                    }
                    else if requestType == "chart"{
                        if let candleData: ChartModel = self.parseJSON(safeData){
                            self.delegate?.didUpdateChartData(self, candlesData: candleData, timeFrame: otherInfo ?? "")
                        }
                    }
                    else if requestType == "currencies"{
                        if let currencies: [String] = self.parseJSON(safeData){
                            self.delegate?.didFetchCurrencies(self, currencies: currencies)
                        }
                    }
                    else if requestType == "rates"{
                        if let rates: [ExchnageRate] = self.parseJSON(safeData){
                            self.delegate?.didFetchExchangeRates(self, rates: rates)
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
    
    func parseJSON(_ data: Data) -> [String]?{
        let decoder = JSONDecoder()
        do{
            let currencies:[String] = try decoder.decode([String].self, from: data)
            return currencies
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSON(_ data: Data) -> [ExchnageRate]?{
        let decoder = JSONDecoder()
        do{
            let rates: ExchangeRates = try decoder.decode(ExchangeRates.self, from: data)
            return rates.data
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    

}

protocol NetworkHandlerDelegate{
    func didUpdateCoinsData(_ networkHandler: NetworkHandler, coinsData: [CoinModel])
    func didFailWithError(error: Error)
    func didUpdateChartData(_ networkHandler: NetworkHandler, candlesData: ChartModel, timeFrame: String)
    func didFetchCurrencies(_ networkHandler: NetworkHandler, currencies: [String])
    func didFetchExchangeRates(_ networkHandler: NetworkHandler, rates: [ExchnageRate])
}
