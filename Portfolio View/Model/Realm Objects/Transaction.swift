//
//  Transaction.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation
import RealmSwift

class Transaction: Object{
    var parentCategory = LinkingObjects(fromType: Coin.self, property: "transactions")
    @objc dynamic private var date: Double = 0
    @objc dynamic private var notes: String = ""
    @objc dynamic private var transactionType: String = ""
    @objc dynamic private var fiatID: String = ""//the id of the pairing coin
    @objc dynamic private var amountOfCoin: Double = 0//the amount gained/lost of the parent coin (as an absolute value, neg/pos is determined by the type)
    @objc dynamic private var amountOfFiat: Double = 0//the amount of the pairing coin gained/lost (as an absolute value)
    
    convenience init(amountReceived: Double){
        self.init()
        self.transactionType = Transaction.typeReceived
        self.amountOfCoin = amountReceived
        self.date = NSDate().timeIntervalSince1970
    }
    
    convenience init(amountSent: Double){
        self.init()
        self.transactionType = Transaction.typeSent
        self.amountOfCoin = amountSent
        self.date = NSDate().timeIntervalSince1970
    }
    
    //buy
    convenience init(amountOfParentCoinBought amountBought: Double, boughtWith id: String, amountOfPairSpent amountSpent: Double){
        self.init()
        self.transactionType = Transaction.typeBought
        self.amountOfCoin = amountBought
        self.fiatID = id
        self.amountOfFiat = amountSpent
        self.date = NSDate().timeIntervalSince1970
    }
    
    //sell
    convenience init(amountOfParentCoinSold amountSold: Double, soldFor id: String, amountOfPairReceived amountReceived: Double){
        self.init()
        self.transactionType = Transaction.typeSold
        self.amountOfCoin = amountSold
        self.fiatID = id
        self.amountOfFiat = amountReceived
        self.date = NSDate().timeIntervalSince1970
    }
    
    //transfer
    convenience init(amountOfParentCoinTransferred amountTransferred: Double, transferredTo id: String, amountOfPairReceived amountReceived: Double){
        self.init()
        self.transactionType = Transaction.typeTransferredFrom
        self.amountOfCoin = amountTransferred
        self.fiatID = id
        self.amountOfFiat = amountReceived
        self.date = NSDate().timeIntervalSince1970
    }
    
    convenience init(amountOfParentCoinReceived amountReceived: Double, transferredFrom id: String, amountOfPairCoinTransferred amountTransferred: Double){
        self.init()
        self.transactionType = Transaction.typeTransferredTo
        self.amountOfCoin = amountReceived
        self.fiatID = id
        self.amountOfFiat = amountTransferred
        self.date = NSDate().timeIntervalSince1970
    }
    
    func setNotes(notes: String){
        self.notes = notes
    }
    
    func getNotes() -> String{
        return notes
    }
    
    func getTransactionType() -> String{
        return transactionType
    }
    
    func getTransactionTypeName() -> String{
        switch transactionType{
        case Transaction.typeSent:
            return "Sent"
        case Transaction.typeSold:
            return "Sold"
        case Transaction.typeBought:
            return "Bought"
        case Transaction.typeReceived:
            return "Received"
        case Transaction.typeTransferredFrom:
            return "Transferred from"
        case Transaction.typeTransferredTo:
            return "Transferred To"
        default:
            return ""
        }
    }
    
    func getPairId() -> String{
        return fiatID
    }
    
    func getAmountOfParentCoin() -> Double{
        return amountOfCoin
    }
    
    func getDate() -> Double{
        return date
    }
    
    func getAmountOfParentCoin() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 8
        return String(numberFormatter.string(from: NSNumber(value: amountOfCoin)) ?? "0")
    }
    
    func getAmountOfPair() -> Double{
        return amountOfFiat
    }
    
    static let typeReceived: String = "received", typeSent = "sent", typeBought = "bought", typeSold = "sold", typeTransferredTo = "transferredTo", typeTransferredFrom = "transferredFrom"
}

