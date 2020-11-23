//
//  StoredCoin.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation
import RealmSwift

class Coin: Object{
    @objc dynamic private var id: String = ""
    @objc dynamic private var symbol: String = ""
    @objc dynamic private var name: String = ""
    @objc dynamic private var priceUsd: Double = 0
    @objc dynamic private var changePercent24Hr: Double = 0
    @objc dynamic private var marketCapUsd: Double = 0
    @objc dynamic private var balance: Double = 0
    @objc dynamic private var balanceValueUsd: Double = 0
    @objc dynamic private var isPinned: Bool = false
    @objc dynamic private var iconImage: NSData = NSData()
    
    private let requestIndex = List<Int>()
    private let pointsRequestIndex = List<Int>()

    
    public static let lineChartRequests: [(exchange: String, quote: String)] = [
        (exchange: "binance" , quote: "tether"),
        (exchange: "huobi"   , quote: "tether"),
        (exchange: "coinbene", quote: "tether"),
        (exchange: "bit-z"   , quote: "tether"),
        (exchange: "binance" , quote: "bitcoin"),
        (exchange: "huobi"   , quote: "bitcoin"),
        (exchange: "coinbene", quote: "bitcoin"),
        (exchange: "bit-z"   , quote: "bitcoin"),
        (exchange: "hotbit"  , quote: "bitcoin"),
        (exchange: "kucoin"  , quote: "bitcoin")
    ]
    
    public static let lineChartTimeFrames: [(timeFrame: String, pointsData: [(pointTimeFrame: String, numOfPoints: Int)])] = [
        (timeFrame: "4H", pointsData: [(pointTimeFrame: "m1" , numOfPoints: 240), (pointTimeFrame: "m5" , numOfPoints: 48)]),
        (timeFrame: "1D", pointsData: [(pointTimeFrame: "m5" , numOfPoints: 288), (pointTimeFrame: "m15", numOfPoints: 96)]),
        (timeFrame: "1W", pointsData: [(pointTimeFrame: "m30", numOfPoints: 336), (pointTimeFrame: "h1" , numOfPoints: 168)]),
        (timeFrame: "1M", pointsData: [(pointTimeFrame: "h2" , numOfPoints: 360), (pointTimeFrame: "h4" , numOfPoints: 180)]),
        (timeFrame: "3M", pointsData: [(pointTimeFrame: "h8" , numOfPoints: 270), (pointTimeFrame: "h12", numOfPoints: 180)]),
        (timeFrame: "6M", pointsData: [(pointTimeFrame: "h12", numOfPoints: 360), (pointTimeFrame: "d1" , numOfPoints: 180)]),
        (timeFrame: "1Y", pointsData: [(pointTimeFrame: "d1" , numOfPoints: 365), (pointTimeFrame: "w1" , numOfPoints: 52)])
    ]
    
    func getTimeFrameIndex(timeFrame: String) -> Int{
        switch timeFrame{
        case "4H":
            return 0
        case "1D":
            return 1
        case "1W":
            return 2
        case "1M":
            return 3
        case "3M":
            return 4
        case "6M":
            return 5
        case "1Y":
            return 6
        default:
            return 0
        }
    }
    
    private let transactions = List<Transaction>()
    private var transactionsArray: [Transaction]{
        get{
            Array(transactions.sorted(byKeyPath: "date", ascending: false))
        }
    }
    
    func requestDidFailShouldTryAgain(timeFrame: String, wasEmpty: Bool) -> Bool{
        let index = getTimeFrameIndex(timeFrame: timeFrame)
        if wasEmpty{
            if requestIndex[index] < Coin.lineChartRequests.count - 1{
                do{
                    try realm!.write{
                        requestIndex[index] += 1
                    }
                    return true
                }catch{
                    print("error saving: \(error)")
                    return false
                }
            }else{
                do{
                    try realm!.write{
                        requestIndex[index] = 0
                    }
                }catch{
                    print("error saving: \(error)")
                }
                return false
            }
        }else{
            if pointsRequestIndex[index] < Coin.lineChartTimeFrames[index].pointsData.count{
                do{
                    try realm!.write{
                        pointsRequestIndex[index] += 1
                    }
                    return true
                }catch{
                    print("error saving: \(error)")
                    return false
                }
            }else{
                do{
                    try realm!.write{
                        pointsRequestIndex[index] = 0
                    }
                }catch{
                    print("error saving: \(error)")
                }
                return false
            }
        }
    }

    convenience init(id: String, symbol: String, name: String) {
        self.init()
        self.id = id
        self.symbol = symbol
        self.name = name
        for _ in 1...7{
            requestIndex.append(0)
            pointsRequestIndex.append(0)
        }
    }
    
    func getID() -> String{
        return id
    }
    
    func getSymbol() -> String{
        return symbol
    }
    
    func getName() -> String{
        return name
    }
    
    private func getPriceUsd() -> Double{
        return priceUsd
    }
    
    func getPrice(withRate rate: Double) -> Double{
        return priceUsd / rate
    }
    
    func getPrice(withRate rate: Double, symbol: String) -> String{
        let price: Double = getPrice(withRate: rate)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if price < 1{
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 6
            numberFormatter.minimumSignificantDigits = 3
            numberFormatter.maximumSignificantDigits = 3
            numberFormatter.roundingMode = .halfUp
        }else{
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
        }
        let formattedPrice = "\(symbol)\(numberFormatter.string(from: NSNumber(value: price)) ?? "0.00")"
        return formattedPrice
    }
    
    func getChangePercent24Hr() -> Double{
        return changePercent24Hr
    }
    
    func getChangePercent24Hr() -> String{
        if changePercent24Hr >= 0{
            return "+\(String(format: "%.2f", changePercent24Hr))%"
        }else{
            return "\(String(format: "%.2f", changePercent24Hr))%"
        }
    }
    
    func getMarketCapUsd() -> Double{
        return marketCapUsd
    }
    
    func getTransactions() -> [Transaction]{
        return transactionsArray
    }
    
    func getPinned() -> Bool{
        return isPinned
    }
    
    func setPriceUsd(to price: Double){
        do{
            try realm!.write(){
                priceUsd = price
            }
        }catch{
            print("error saving: \(error)")
        }
        calculateBalanceValueUsd()
    }
    
    func setChangePercent24Hr(to change: Double){
        do{
            try realm!.write(){
                changePercent24Hr = change
            }
        }catch{
            print("error saving: \(error)")
        }
    }
    
    func setMarketCapUsd(to cap: Double){
        do{
            try realm!.write(){
                marketCapUsd = cap
            }
        }catch{
            print("error saving: \(error)")
        }
    }
    
    func setPinned(to pinned: Bool){
        do{
            try realm!.write(){
                isPinned = pinned
            }
        }catch{
            print("error saving: \(error)")
        }
    }
    
    func addTransaction(_ transaction: Transaction){
        do{
            try self.realm!.write{
                transactions.append(transaction)
            }
        }catch{
            print("Error saving: \(error)")
        }
        calculateBalance()
    }
    
    func deleteTransaction(_ transaction: Transaction){
        do{
            try realm!.write{
                realm?.delete(transaction)
            }
        }catch{
            print("error deleting: \(error)")
        }
        calculateBalance()
    }
    
    private func calculateBalance(){
        var balance: Double = 0
        for transaction: Transaction in transactionsArray{
            let type: String = transaction.getTransactionType()
            if type == Transaction.typeSent || type == Transaction.typeSold || type == Transaction.typeTransferredFrom{
                balance -= transaction.getAmountOfParentCoin()
            }
            else if type == Transaction.typeReceived || type == Transaction.typeBought || type == Transaction.typeTransferredTo{
                balance += transaction.getAmountOfParentCoin()
            }
        }
        do{
            try realm!.write{
                self.balance = balance
            }
        }catch{
            print("error deleting: \(error)")
        }
        calculateBalanceValueUsd()
    }
    
    private func calculateBalanceValueUsd(){
        do{
            try realm!.write{
                self.balanceValueUsd = priceUsd * balance
            }
        }catch{
            print("error deleting: \(error)")
        }
    }
    
    func getBalance() -> Double{
        return balance
    }
    
    func getBalance() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 8
        return String(numberFormatter.string(from: NSNumber(value: balance)) ?? "0")
    }
    
    func getBalanceValue(withRate rate: Double) -> Double{
        return getPrice(withRate: rate) * balance
    }
    
//    func getBalanceValue(withRate rate: Double, symbol: String) -> String{
//        let balanceValue: Double = getBalanceValue(withRate: rate)
//            
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//        numberFormatter.minimumFractionDigits = 2
//        numberFormatter.maximumFractionDigits = 2
//        let formattedBalance = "\(symbol)\(numberFormatter.string(from: NSNumber(value: balanceValue)) ?? "0.00")"
//        return formattedBalance
//    }
    
    func getLineChartQuoteID(timeFrame: String) -> String{
        return Coin.lineChartRequests[requestIndex[getTimeFrameIndex(timeFrame: timeFrame)]].quote
    }
    
    func getLineChartExchange(timeFrame: String) -> String{
        return Coin.lineChartRequests[requestIndex[getTimeFrameIndex(timeFrame: timeFrame)]].exchange
    }
    
    func getPointTimeFrame(timeFrame: String) -> String{
        return Coin.lineChartTimeFrames[getTimeFrameIndex(timeFrame: timeFrame)].pointsData[pointsRequestIndex[getTimeFrameIndex(timeFrame: timeFrame)]].pointTimeFrame
    }
    
    func getNumOfPoints(timeFrame: String) -> Int{
        return Coin.lineChartTimeFrames[getTimeFrameIndex(timeFrame: timeFrame)].pointsData[pointsRequestIndex[getTimeFrameIndex(timeFrame: timeFrame)]].numOfPoints
    }
}
