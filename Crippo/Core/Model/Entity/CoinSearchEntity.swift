//
//  CoinSearchEntity.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

struct CoinSearchEntity: Hashable, Identifiable {
    let id = UUID()
    let coinID: String
    let name: String
    let symbol: String
    let thumb: String
    let large: String
}
