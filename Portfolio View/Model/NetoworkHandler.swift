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
    
    func fetchCoinData(){
        let url: String = "https://api.coincap.io/v2/assets?limit=110"
        performRequest(with: url, requestType: "coinData", otherInfo: nil)
    }
    
    func fetchCurrencyData(){
        let url: String = "https://api.coincap.io/v2/rates"
        performRequest(with: url, requestType: "rateData", otherInfo: nil)
    }
    
    func fetchCandleData(exchange: String, interval: String, baseID: String, quoteID: String, timeFrame: String){
        let url: String = "https://api.coincap.io/v2/candles?exchange=\(exchange)&interval=\(interval)&baseId=\(baseID)&quoteId=\(quoteID)"
        performRequest(with: url, requestType: "candle", otherInfo: timeFrame)
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
                        if let coinsData: AllCoinsModel = self.parseJSON(safeData){
                            self.delegate?.didUpdateCoinsData(self, coinsData: coinsData)
                        }
                    }
                    else if requestType == "rateData"{
                        if let exchangeRatesData: AllCurrenciesModel = self.parseJSON(safeData){
                            self.delegate?.didUpdateCurrencyData(self, CurrenciesData: exchangeRatesData)
                        }
                    }
                    else if requestType == "candle"{
                        if let candleData:AllCandlesModel = self.parseJSON(safeData){
                            self.delegate?.didUpdateCandleData(self, candlesData: candleData, timeFrame: otherInfo ?? "")
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> AllCoinsModel?{
        let decoder = JSONDecoder()
        do{
            let coinsData = try decoder.decode(AllCoinsModel.self, from: data)
            return coinsData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSON(_ data: Data) -> AllCurrenciesModel?{
        let decoder = JSONDecoder()
        do{
            let exchangeRatesData = try decoder.decode(AllCurrenciesModel.self, from: data)
            return exchangeRatesData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSON(_ data: Data) -> AllCandlesModel?{
        let decoder = JSONDecoder()
        do{
            let candlesData:AllCandlesModel = try decoder.decode(AllCandlesModel.self, from: data)
            return candlesData
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

protocol NetworkHandlerDelegate{
    func didUpdateCoinsData(_ networkHandler: NetworkHandler, coinsData: AllCoinsModel)
    func didUpdateCurrencyData(_ networkHandler: NetworkHandler, CurrenciesData: AllCurrenciesModel)
    func didFailWithError(error: Error)
    func didUpdateCandleData(_ networkHandler: NetworkHandler, candlesData: AllCandlesModel, timeFrame: String)
}
