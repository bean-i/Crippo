//
//  NFTModel.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

struct NFT: Identifiable {
    let id = UUID()
    let name: String
    let priceETH: String
    let changePercent: Double
    let iconName: String
}
