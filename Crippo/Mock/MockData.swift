//
//  MockData.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

// MARK: - 목 데이터 정의
struct SearchCoin: Identifiable, Codable, Hashable {
    let id: String       // ex. "bitcoin"
    let name: String     // ex. "Bitcoin"
    let symbol: String   // ex. "BTC"
    let thumb: URL?      // ex. URL(string: ".../thumb/bitcoin.png")
}

// MARK: — Coin Market API Models

/// /api/v3/coins/markets?vs_currency=krw&ids={ids}&sparkline=true
struct MarketCoin: Identifiable, Codable, Hashable {
    let id: String               // Coin ID
    let name: String             // Coin 이름
    let symbol: String           // ex. "BTC"
    let image: URL?              // 코인 아이콘 URL
    let currentPrice: Double     // 현재가
    let priceChange24h: Double   // 24h 변동률
    let low24h: Double           // 24h 최저가
    let high24h: Double          // 24h 최고가
    let ath: Double              // All‑Time High (신고점)
    let athDate: Date?           // 신고점 일자
    let atl: Double              // All‑Time Low (신저점)
    let atlDate: Date?           // 신저점 일자
    let lastUpdated: Date?       // 시장 데이터 업데이트 시각
    let sparklineIn7d: SparklineIn7d?  // 7일간 시세

    enum CodingKeys: String, CodingKey {
        case id, name, symbol, image
        case currentPrice         = "current_price"
        case priceChange24h       = "price_change_percentage_24h"
        case low24h               = "low_24h"
        case high24h              = "high_24h"
        case ath, athDate         = "ath_date"
        case atl, atlDate         = "atl_date"
        case lastUpdated          = "last_updated"
        case sparklineIn7d        = "sparkline_in_7d"
    }
}

/// Market API 의 sparkline_in_7d.price 배열
struct SparklineIn7d: Codable, Hashable {
    let price: [Double]
}

// MARK: — 목 데이터

enum MockData {
    /// SearchView 에 표시할 예시 결과
    static let searchCoins: [SearchCoin] = [
        .init(id: "bitcoin",
              name: "Bitcoin",
              symbol: "BTC",
              thumb: URL(string: "https://assets.coingecko.com/coins/images/1/thumb/bitcoin.png")),
        .init(id: "ethereum",
              name: "Ethereum",
              symbol: "ETH",
              thumb: URL(string: "https://assets.coingecko.com/coins/images/279/thumb/ethereum.png")),
        .init(id: "solana",
              name: "Solana",
              symbol: "SOL",
              thumb: URL(string: "https://assets.coingecko.com/coins/images/4128/thumb/solana.png"))
    ]

    /// ChartView 에 표시할 예시 MarketCoin
    static let marketCoins: [MarketCoin] = [
        MarketCoin(
            id: "solana",
            name: "Solana",
            symbol: "SOL",
            image: URL(string: "https://assets.coingecko.com/coins/images/4128/large/solana.png"),
            currentPrice: 69234245,
            priceChange24h: 3.22,
            low24h: 69000000,
            high24h: 69500000,
            ath: 74000000,
            athDate: isoFormatter.date(from: "2025-02-20T10:00:00.000Z"),
            atl: 8000,
            atlDate: isoFormatter.date(from: "2021-06-01T00:00:00.000Z"),
            lastUpdated: isoFormatter.date(from: "2025-02-21T11:53:50.000Z"),
            sparklineIn7d: SparklineIn7d(price: MockData.sparkline)
        )
    ]

    /// 7일치 시세 모의 데이터 (여기선 30개만)
    static let sparkline: [Double] = [
        50, 55, 53, 60, 58, 62, 70, 68, 75, 80,
        78, 85, 83, 90, 95, 92, 100, 98, 105, 110,
        108, 115, 112, 120, 118, 125, 130, 128, 135, 140
    ]

    private static var isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}
