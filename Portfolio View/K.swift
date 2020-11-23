//
//  K.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation

struct K{
   static func convertCommasToDots(_ input: String) -> String {
        return String(input.map {
            $0 == "," ? "." : $0
        })
    }
    
    static func convertToMoneyFormat(_ input: Double, symbol: String) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        let formattedBalance = "\(symbol)\(numberFormatter.string(from: NSNumber(value: input)) ?? "0.00")"
        return formattedBalance
    }
}
