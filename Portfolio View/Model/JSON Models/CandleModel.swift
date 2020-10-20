//
//  CandleData.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-28.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation

struct AllCandlesModel: Decodable{
    let data:[CandleModel]
}

struct CandleModel: Decodable{
    var open: String
    var period: Double
}

