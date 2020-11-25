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
    @objc dynamic private var image: String = ""
    @objc dynamic private var price: Double = 0
    @objc dynamic private var marketCapRank: Int = 0
    @objc dynamic private var changePercentage24h: Double = 0
    @objc dynamic private var balance: Double = 0
    @objc dynamic private var balanceValue: Double = 0
    @objc dynamic private var isPinned: Bool = false
    @objc dynamic private var iconImage: NSData = NSData()
    
    private let transactions = List<Transaction>()

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
    
    func getPrice() -> Double{
        return price
    }
    
    func getChangePercentage24h() -> Double{
        return changePercentage24h
    }
    
    func getTransactions() -> [Transaction]{
        return Array(transactions.sorted(byKeyPath: "date", ascending: false))
    }
    
    func getPinned() -> Bool{
        return isPinned
    }
    
    func setPrice(_ value: Double){
        do{
            try realm!.write(){
                price = value
            }
        }catch{
            print("error saving: \(error)")
        }
        calculateBalanceValue()
    }
    
    func setChangePercent24h(_ value: Double){
        do{
            try realm!.write(){
                changePercentage24h = value
            }
        }catch{
            print("error saving: \(error)")
        }
    }
    
    func setMarketCapRank(_ value: Int){
        do{
            try realm!.write(){
                marketCapRank = value
            }
        }catch{
            print("error saving: \(error)")
        }
    }
    
    func setPinned(_ value: Bool){
        do{
            try realm!.write(){
                isPinned = value
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
        for transaction: Transaction in transactions{
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
        calculateBalanceValue()
    }
    
    private func calculateBalanceValue(){
        do{
            try realm!.write{
                self.balanceValue = price * balance
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
    
    func getBalanceValue() -> Double{
        return price * balance
    }
}
