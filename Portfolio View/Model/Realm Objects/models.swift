//
//  models.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-12-18.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation

struct CoinModel: Decodable{
    let id: String
    let symbol: String?
    let name: String?
    let image: String?
    let current_price: Double?
    let price_change_percentage_1h_in_currency: Double?
    let price_change_percentage_24h: Double?
    let price_change_percentage_7d_in_currency: Double?
    let price_change_percentage_30d_in_currency: Double?
    let price_change_percentage_1y_in_currency: Double?
    let market_cap_rank: Int?
}

struct ChartModel: Decodable{
    let prices: [[Double]]
}

struct ExchangeRate: Decodable{
    let symbol: String
    let rateUsd: String
}

struct ExchangeRateData: Decodable{
    let data: [ExchangeRate]
}

struct AvailbleCoin: Decodable{
    let id: String
    let symbol: String?
    let name: String?
}

