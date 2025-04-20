//
//  CoinSearchResponseDTO.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

struct CoinSearchResponseDTO: Decodable {
    let coins: [DetailCoin]
}

struct DetailCoin: Decodable {
    let id: String
    let name: String
    let symbol: String
    let rank: Int
    let thumb: String
    let large: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, thumb, large
        case rank = "market_cap_rank"
    }
}

extension CoinSearchResponseDTO {
    static let empty = CoinSearchResponseDTO(coins: [])
}

extension DetailCoin {
    func toEntity() -> CoinSearchEntity {
        return CoinSearchEntity(
            coinID: self.id,
            name: self.name,
            symbol: self.symbol,
            thumb: self.thumb,
            large: self.large
        )
    }
}
