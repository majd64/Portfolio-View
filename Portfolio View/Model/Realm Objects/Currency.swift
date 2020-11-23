//
//  ExchangeRate.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-25.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation
import RealmSwift

class Currency: Object{
    @objc dynamic private var id: String = ""
    @objc dynamic private var symbol: String = ""
    @objc dynamic private var currencySymbol: String = ""
    @objc dynamic private var rateUsd: Double = 0
    
    convenience init(id: String, symbol: String, currencySymbol: String) {
        self.init()
        self.id = id
        self.symbol = symbol
        self.currencySymbol = currencySymbol
    }
    
    func getId() -> String{
        return id
    }
    
    func getSymbol() -> String{
        return symbol
    }
    
    func getCurrencySymbol() -> String{
        return currencySymbol
    }
    
    func getRateUsd() -> Double{
        return rateUsd
    }
    
    func setRateUsd(to rate: Double){
        do{
            try realm!.write(){
                rateUsd = rate
            }
        }catch{
            print("error saving: \(error)")
        }
    }
}
