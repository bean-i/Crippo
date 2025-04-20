//
//  TrendingCoinEntity.swift
//  Crippo
//
//  Created by 이빈 on 4/20/25.
//

import Foundation

struct TrendingCoinEntity: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let thumbUrl: String
    let price: String
    let changePercentage: String
    let isPositiveChange: Bool
}
