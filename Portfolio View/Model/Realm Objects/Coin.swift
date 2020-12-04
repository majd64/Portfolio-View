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
    @objc dynamic private var secondaryPrice: Double = 0
    @objc dynamic private var marketCapRank: Int = 0
    @objc dynamic private var changePercentage24h: Double = 0
    @objc dynamic private var balance: Double = 0
    @objc dynamic private var balanceValue: Double = 0
    @objc dynamic private var isPinned: Bool = false
    @objc dynamic private var iconImage: NSData = NSData()
    @objc dynamic private var colorHex: String = "D3D3D3"
    @objc dynamic private var coinVersion: Int = 0
    
    @objc dynamic private var changePercentage1h: Double = 0
    @objc dynamic private var changePercentage1w: Double = 0
    @objc dynamic private var changePercentage1m: Double = 0
    @objc dynamic private var changePercentage1y: Double = 0
    
    
    let transactions = List<Transaction>()

    convenience init(id: String, symbol: String, name: String, image: String) {
        self.init()
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
        do{
            try self.iconImage = NSData(contentsOf: (URL(string: image)!))
        }catch{}
        
        self.getImage()?.getColors { colors in
//          backgroundView.backgroundColor = colors.background
            do{
                try self.realm!.write(){
                    self.colorHex = K.hexStringFromColor(color: colors?.background.withAlphaComponent(0.8) ?? UIColor.gray)
                }
            }catch{
                fatalError("error saving: \(error)")
            }
            
//          secondaryLabel.textColor = colors.secondary
//          detailLabel.textColor = colors.detail
        }
    }
    
    func getCoinVersion() -> Int{
        return coinVersion
    }
    
    func setCoinVersion(_ value: Int){
        do{
            try realm!.write(){
                coinVersion = value
            }
        }catch{
            print("error saving: \(error)")
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
    
    func getImage() -> UIImage?{
        return UIImage(data: self.iconImage as Data)
    }
    
    func getColor() -> UIColor{
        return K.colorWithHexString(hexString: self.colorHex)
    }
    
    func getPrice() -> Double{
        return price
    }
    
    func getSecondaryPrice() -> Double{
        return secondaryPrice
    }
    
    func getChangePercentage24h() -> String{
        if (changePercentage24h > 0){
            
            return "+\(String(format: "%.2f", changePercentage24h))%"
        }else{
            return "\(String(format: "%.2f", changePercentage24h))%"
        }
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
    
    //=====
    
    func getChangePercentage1h() -> Double{
        return changePercentage1h
    }
    
    
    func setChangePercent1h(_ value: Double){
        do{
            try realm!.write(){
                changePercentage1h = value
            }
        }catch{
            print("error saving: \(error)")
        }
    }
    
    func getChangePercentage1w() -> Double{
        return changePercentage1w
    }
    
    
    func setChangePercent1w(_ value: Double){
        do{
            try realm!.write(){
                changePercentage1w = value
            }
        }catch{
            print("error saving: \(error)")
        }
    }
    
    func getChangePercentage1m() -> Double{
        return changePercentage1m
    }
    
    
    func setChangePercent1m(_ value: Double){
        do{
            try realm!.write(){
                changePercentage1m = value
            }
        }catch{
            print("error saving: \(error)")
        }
    }
    
    func getChangePercentage1y() -> Double{
        return changePercentage1y
    }
    
    
    func setChangePercent1y(_ value: Double){
        do{
            try realm!.write(){
                changePercentage1y = value
            }
        }catch{
            print("error saving: \(error)")
        }
    }
    
    
    
}
