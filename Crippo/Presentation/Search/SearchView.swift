//
//  SearchView.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import SwiftUI

struct SearchView: View {
    @State private var path: [SearchCoin] = []
    @State private var query = ""
    @State private var results: [SearchCoin] = MockData.searchCoins
    @State private var favorites: Set<String> = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(results) { coin in
                    SearchResultRow(
                        coin: coin,
                        query: query,
                        isFavorited: favorites.contains(coin.id),
                        onSelect:   { path.append(coin) },
                        onFavorite: {
                            if favorites.contains(coin.id) {
                                favorites.remove(coin.id)
                            } else {
                                favorites.insert(coin.id)
                            }
                        }
                    )
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .searchable(text: $query, prompt: "코인 검색")
            .onSubmit(of: .search) {
                // 실제 네트워크 호출 대신 목데이터 필터
                results = MockData.searchCoins.filter {
                    $0.name.lowercased().contains(query.lowercased()) ||
                    $0.symbol.lowercased().contains(query.lowercased())
                }
            }
            .navigationTitle("Search")
            .navigationDestination(for: SearchCoin.self) { coin in
                ChartView(coin: MockData.marketCoins.first!)
//                if let market = MockData.marketCoins.first(where: { $0.id == coin.id }) {
//                    ChartView(coin: market)
//                } else {
//                    Text("데이터 없음")
//                }
            }
        }
    }
}

// MARK: - 코인 검색 결과 Row
private struct SearchResultRow: View {
    let coin: SearchCoin
    let query: String
    let isFavorited: Bool
    let onSelect: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // 썸네일
                AsyncImage(url: coin.thumb) { img in
                    img.resizable()
                       .aspectRatio(1, contentMode: .fit)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 32, height: 32)
                .cornerRadius(4)

                // 이름/심볼
                VStack(alignment: .leading, spacing: 2) {
                    HighlightedText(fullText: coin.name, highlight: query)
                        .font(.body)
                    Text(coin.symbol)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                // 별 버튼
                Button(action: onFavorite) {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .foregroundColor(.point)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
    }
}

struct HighlightedText: View {
    let fullText: String
    let highlight: String
    
    var body: some View {
        // 대소문자 구분 없이 매칭
        if let range = fullText.lowercased().range(of: highlight.lowercased()), !highlight.isEmpty {
            let start = String(fullText[..<range.lowerBound])
            let match = String(fullText[range])
            let end   = String(fullText[range.upperBound...])
            
            HStack(spacing: 0) {
                Text(start)
                Text(match)
                    .foregroundColor(.point)
                Text(end)
            }
        } else {
            Text(fullText)
        }
    }
}

#Preview {
    SearchView()
}
