//
//  CoinModel.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

struct Coin: Hashable ,Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let priceKRW: String
    let changePercent: Double
    let iconName: String
}
