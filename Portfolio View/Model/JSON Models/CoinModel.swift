//
//  CoinDataJSONModel.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-25.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation

struct CoinModel: Decodable{
    let id: String
    let symbol: String?
    let name: String?
    let image: String?
    let current_price: Double?
    let price_change_percentage_24h: Double?
    let market_cap_rank: Int?
}
