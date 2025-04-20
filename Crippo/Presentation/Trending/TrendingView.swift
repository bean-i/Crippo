//
//  TrendingView.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import SwiftUI

import Combine

// MARK: - TrendingView
struct TrendingView: View {
    @StateObject private var viewModel = TrendingViewModel()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // My Favorite 섹션 (즐겨찾기 2개 이상일 때만 표시)
                    if viewModel.output.favoriteCoins.count >= 2 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("My Favorite")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.output.favoriteCoins, id: \.coinID) { coin in
                                        FavoriteCoinCard(
                                            coin: coin,
                                            onTap: {
                                                viewModel.action(.coinSelected(coin.coinID))
                                            }
                                        )
                                        .frame(width: 180)
                                        .padding(.vertical, 10)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    
                    // Top 15 Coin 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top 15 Coin")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.output.trendingCoins.enumerated()), id: \.element.id) { index, coin in
                                TrendingCoinRow(index: index + 1, coin: coin)
                                    .onTapGesture {
                                        viewModel.action(.coinSelected(coin.id))
                                        navigationPath.append(coin.id)
                                    }
                                
                                if index < viewModel.output.trendingCoins.count - 1 {
                                    Divider()
                                        .padding(.leading, 40)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Top 7 NFT 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top 7 NFT")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.output.trendingNFTs.enumerated()), id: \.element.name) { index, nft in
                                TrendingNFTRow(index: index + 1, nft: nft)
                                
                                if index < viewModel.output.trendingNFTs.count - 1 {
                                    Divider()
                                        .padding(.leading, 40)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Crypto Coin")
            .onAppear {
                viewModel.action(.viewAppeared)
            }
            .navigationDestination(for: String.self) { coinID in
                ChartView(coinID: coinID)
            }
        }
    }
}

// MARK: - TrendingCoinRow
struct TrendingCoinRow: View {
    let index: Int
    let coin: TrendingCoinEntity
    
    var body: some View {
        HStack(spacing: 12) {
            // 인덱스
            Text("\(index)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            // 코인 이미지
            AsyncImage(url: URL(string: coin.thumbUrl)) { image in
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
                    .font(.subheadline)
                Text(coin.symbol)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 가격 및 변동률
            VStack(alignment: .trailing, spacing: 2) {
                Text(coin.price)
                    .font(.subheadline)
                
                Text(coin.changePercentage)
                    .font(.caption)
                    .foregroundColor(coin.isPositiveChange ? .red : .blue)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - TrendingNFTRow
struct TrendingNFTRow: View {
    let index: Int
    let nft: TrendingNFTEntity
    
    var body: some View {
        HStack(spacing: 12) {
            // 인덱스
            Text("\(index)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            // NFT 이미지
            AsyncImage(url: URL(string: nft.thumbUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 32, height: 32)
            .cornerRadius(6)
            
            // NFT 이름
            Text(nft.name)
                .font(.subheadline)
            
            Spacer()
            
            // 가격 및 변동률
            VStack(alignment: .trailing, spacing: 2) {
                Text(nft.floorPrice)
                    .lineLimit(1)
                    .font(.subheadline)
                
                Text(nft.floorPercentage)
                    .font(.caption)
                    .foregroundColor(nft.isPositiveChange ? .red : .blue)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}


#Preview {
    TrendingView()
}
