//
//  CoinDataJSONModel.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-25.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation

struct AllCoinsModel: Decodable{
    let data:[CoinModel]
}

struct CoinModel: Decodable{
    let id: String
    let symbol: String?
    let name: String?
    let marketCapUsd: String?
    let priceUsd: String?
    let changePercent24Hr: String?
}
