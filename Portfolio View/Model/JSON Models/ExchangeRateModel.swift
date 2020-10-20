//
//  RatesData.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-25.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation

struct AllExchangeRatesModel: Decodable{
    let data: [ExchangeRateModel]
}

struct ExchangeRateModel: Decodable{
    let id: String
    let symbol: String?
    let currencySymbol: String?
    let rateUsd: String?
}
