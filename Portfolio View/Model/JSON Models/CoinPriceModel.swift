//
//  CoinPriceModel.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-25.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation

struct CoinPriceModel: Decodable{
    let price: Price
}

struct Price: Decodable{
    let price: Double
}
