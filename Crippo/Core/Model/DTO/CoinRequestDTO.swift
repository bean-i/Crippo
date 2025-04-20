//
//  CoinRequestDTO.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

enum CoinRequestDTO {
    
    case coinSearch(String)
    case coinMarket(String)
    
    var queryParameters: Encodable {
        switch self {
        case .coinSearch(let query):
            return CoinSearchRequestDTO(query: query)
        case .coinMarket(let id):
            return CoinMarketRequestDTO(ids: id)
        }
    }
    
}

struct CoinSearchRequestDTO: Encodable {
    let query: String
}

struct CoinMarketRequestDTO: Encodable {
    let vs_currency = "krw"
    let ids: String
    let sparkline = "true"
}
