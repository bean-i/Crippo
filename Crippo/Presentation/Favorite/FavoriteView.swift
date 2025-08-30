//
//  FavoriteView.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import SwiftUI
import Combine

// MARK: - FavoriteView
struct FavoriteView: View {
    @StateObject private var viewModel = FavoriteViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.output.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.output.favoriteCoins.isEmpty {
                    Text("즐겨찾기한 코인이 없습니다")
                        .font(.headline)
                        .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16),
                                GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ForEach(viewModel.output.favoriteCoins, id: \.coinID) { coinData in
                                FavoriteCoinCard(
                                    coin: coinData,
                                    onTap: {
                                        viewModel.action(.coinCardTapped(coinData.coinID))
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("お気に入りコイン")
            .navigationDestination(isPresented: Binding(
                get: { viewModel.output.selectedCoinID != nil },
                set: { if !$0 { viewModel.action(.clearSelectedCoin) } }
            )) {
                if let coinID = viewModel.output.selectedCoinID {
                    ChartView(coinID: coinID)
                }
            }
            .onAppear {
                viewModel.action(.viewAppeared)
            }
        }
    }
}

// MARK: - FavoriteCoinCard
struct FavoriteCoinCard: View {
    let coin: CoinMarketEntity
    let onTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 12) {
                // 코인 정보 헤더
                HStack(spacing: 8) {
                    // 코인 이미지
                    AsyncImage(url: URL(string: coin.image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(width: 32, height: 32)
                    
                    // 코인 이름 및 심볼
                    VStack(alignment: .leading, spacing: 2) {
                        Text(coin.name)
                            .font(.headline)
                            .lineLimit(1)
                        Text(coin.coinID)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                // 가격 정보
                Text(coin.currentPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)
                // 가격 정보와 변동률을 같은 행에 배치
                HStack(alignment: .center) {
                    Spacer()
                    // 변동률
                    Text(coin.priceChange24h)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(coin.priceChange24h.first! == "+" ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                        .foregroundColor(coin.priceChange24h.first! == "+" ? .red : .blue)
                        .cornerRadius(8)
                }
            }
            .padding()
            .frame(width: geometry.size.width, height: 150)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .frame(height: 150)
        .onTapGesture {
            onTap()
        }
    }
}
