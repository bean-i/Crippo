//
//  CoinMarketEntity.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

struct CoinMarketEntity {
    let coinID: String
    let name: String
    let image: String
    let currentPrice: String
    let priceChange24h: String
    let lastUpdate: String
    let low24h: String
    let high24h: String
    let allTimeHighPrice: String
    let allTimeHighPriceDate: String
    let allTimeLowPrice: String
    let allTimeLowPriceDate: String
    let marketCap: String
    let fullyDilutedValue: String
    let totalVolume: String
    let sparkline: SparkLinePrice
}

extension CoinMarketEntity {
    static let empty = CoinMarketEntity(
        coinID: "",
        name: "",
        image: "",
        currentPrice: "",
        priceChange24h: "",
        lastUpdate: "",
        low24h: "",
        high24h: "",
        allTimeHighPrice: "",
        allTimeHighPriceDate: "",
        allTimeLowPrice: "",
        allTimeLowPriceDate: "",
        marketCap: "",
        fullyDilutedValue: "",
        totalVolume: "",
        sparkline: SparkLinePrice(price: [])
    )
}
