//
//  CoinEndPoint.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

enum CoinEndPoint: EndPoint {
    
    case coinSearch(String)
    case coinMarket(String)
    case trending
    
    var baseURL: String? { return APIKey.BaseURL }
    
    var path: String {
        switch self {
        case .coinSearch:
            return "/search"
        case .coinMarket:
            return "/coins/markets"
        case .trending:
            return "/search/trending"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var decoder: JSONDecoder { return JSONDecoder() }
    
    var encoder: JSONEncoder { return JSONEncoder() }
    
    var parameters: Encodable {
        switch self {
        case .coinSearch(let query):
            return CoinRequestDTO.coinSearch(query).queryParameters
        case .coinMarket(let id):
            return CoinRequestDTO.coinMarket(id).queryParameters
        case .trending:
            return EmptyParameters()
        }
    }
    
    func error(_ statusCode: Int?, data: Data) -> any Error {
        return URLError(.unknown)
    }
}
