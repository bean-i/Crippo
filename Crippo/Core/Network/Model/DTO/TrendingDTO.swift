//
//  TrendingDTO.swift
//  Crippo
//
//  Created by 이빈 on 4/20/25.
//

import Foundation

// MARK: - Trending API Model
struct TrendingDTO: Decodable {
    let coins: [SearchCoin]
    let nfts: [SearchNFT]
    
    static let empty = TrendingDTO(
        coins: [],
        nfts: []
    )
}

// MARK: - NFT
struct SearchNFT: Decodable {
    let name: String
    let symbol: String
    let thumb: String
    let data: NFTData
}

struct NFTData: Decodable {
    let floorPrice: String
    let floorPercentage: String
    
    enum CodingKeys: String, CodingKey {
        case floorPrice = "floor_price"
        case floorPercentage = "floor_price_in_usd_24h_percentage_change"
    }
}

// MARK: - Coin
struct SearchCoin: Decodable {
    let item: Item
}

struct Item: Decodable {
    let id: String
    let symbol: String
    let name: String
    let thumb: String
    let small: String
    let large: String
    let data: CoinData
}

struct CoinData: Decodable {
    let price: Double
    let changePercentage: CoinPercentage
    
    enum CodingKeys: String, CodingKey {
        case changePercentage = "price_change_percentage_24h"
        case price
    }
}

struct CoinPercentage: Decodable {
    let krw: Double
}


// MARK: - Extension for toEntity conversion
extension TrendingDTO {
    func toEntity() -> TrendingEntity {
        let coinEntities = coins.prefix(15).map { $0.toEntity() }
        let nftEntities = nfts.prefix(7).map { $0.toEntity() }
        
        return TrendingEntity(
            trendingCoins: coinEntities,
            trendingNFTs: nftEntities
        )
    }
}

extension SearchNFT {
    func toEntity() -> TrendingNFTEntity {
        let percentChange = Double(data.floorPercentage) ?? 0.0
        let percentageString = percentChange >= 0 ?
            "+\(String(format: "%.2f", percentChange))%" :
            "\(String(format: "%.2f", percentChange))%"
        
        return TrendingNFTEntity(
            name: name,
            thumbUrl: thumb,
            floorPrice: "\(data.floorPrice) \(symbol)",
            floorPercentage: percentageString,
            isPositiveChange: percentChange >= 0
        )
    }
}

extension SearchCoin {
    func toEntity() -> TrendingCoinEntity {
        return item.toEntity()
    }
}

extension Item {
    func toEntity() -> TrendingCoinEntity {
        let percentChange = data.changePercentage.krw
        let percentageString = percentChange >= 0 ?
            "+\(String(format: "%.2f", percentChange))%" :
            "\(String(format: "%.2f", percentChange))%"
        
        return TrendingCoinEntity(
            id: id,
            name: name,
            symbol: symbol,
            thumbUrl: thumb,
            price: "$\(String(format: "%.4f", data.price))",
            changePercentage: percentageString,
            isPositiveChange: percentChange >= 0
        )
    }
}
