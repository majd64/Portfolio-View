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
    @objc dynamic private var requestIndex: Int = 0
    @objc dynamic private var iconImage: NSData = NSData()
    
    public static let lineChartRequests: [(exchange: String, quote: String)] = [(exchange: "binance", quote: "tether"), (exchange: "huobi", quote: "tether"), (exchange: "binance", quote: "bitcoin"), (exchange: "huobi", quote: "bitcoin"), (exchange: "hotbit", quote: "bitcoin")]
    
    private let transactions = List<Transaction>()
    private var transactionsArray: [Transaction]{
        get{
            Array(transactions.sorted(byKeyPath: "date", ascending: true))
        }
    }
    
    func didAdjustLineChartRequest() -> Bool{
        if requestIndex != Coin.lineChartRequests.count - 1{
            do{
                try realm!.write{
                    requestIndex += 1
                }
            }catch{
                print("error saving: \(error)")
            }
            return true
        }
        return false
    }

    convenience init(id: String, symbol: String, name: String) {
        self.init()
        self.id = id
        self.symbol = symbol
        self.name = name
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
    
    func getBalanceValue(withRate rate: Double, symbol: String) -> String{
        let balanceValue: Double = getBalanceValue(withRate: rate)
            
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        let formattedBalance = "\(symbol)\(numberFormatter.string(from: NSNumber(value: balanceValue)) ?? "0.00")"
        return formattedBalance
    }
    
    func getLineChartQuoteID() -> String{
        return Coin.lineChartRequests[requestIndex].quote
    }
    
    func getLineChartExchange() -> String{
        return Coin.lineChartRequests[requestIndex].exchange
    }
}
