//
//  CoinClient.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

final class CoinClient {
    
    static let shared = CoinClient()
    private let provider = NetworkProvider<CoinEndPoint>()
    private init() { }
    
    func searchCoin(query: String) async throws -> CoinSearchResponseDTO {
        do {
            return try await provider.request(.coinSearch(query))
        } catch {
            throw error
        }
    }
    
    func coinMarket(id: String) async throws -> [CoinMarketResponseDTO] {
        do {
            return try await provider.request(.coinMarket(id))
        } catch {
            print(error)
            throw error
        }
    }
    
}
