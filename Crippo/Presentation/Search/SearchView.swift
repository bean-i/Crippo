//
//  SearchView.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import SwiftUI

struct SearchView: View {
    
    @StateObject private var viewModel = SearchViewModel()
    @State private var path: [CoinSearchEntity] = []
    @State private var query = ""
    
    private var isShowingToast: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.output.showToast },
            set: { viewModel.output.showToast = $0 }
        )
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(viewModel.output.results, id: \.id) { coin in
                    SearchResultRow(
                        viewModel: viewModel,
                        coin: coin,
                        query: query,
                        onTap: {
                            path.append(coin)
                        }
                    )
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .searchable(text: $query, prompt: "코인 검색")
            .onSubmit(of: .search) {
                viewModel.action(.searchQuery(query))
            }
            .navigationTitle("Search")
            .navigationDestination(for: CoinSearchEntity.self) { coin in
                ChartView(coinID: coin.coinID)
            }
            .onAppear {
                viewModel.updateFavoriteStatus()
            }
        }
        .toast(
            isShowing: isShowingToast,
            message: viewModel.output.toastMessage ?? ""
        )
    }
}

// MARK: - 코인 검색 결과 Row
private struct SearchResultRow: View {
    @ObservedObject var viewModel: SearchViewModel
    let coin: CoinSearchEntity
    let query: String
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 썸네일
            AsyncImage(url: URL(string: coin.thumb)) { img in
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
            Button {
                viewModel.action(.toggleFavorite(coin.coinID))
            } label: {
                Image(systemName: viewModel.output.favoriteIDs.contains(coin.coinID) ? "star.fill" : "star")
                    .foregroundColor(.point)
            }
            .buttonStyle(PlainButtonStyle())  // 버튼이 부모 onTapGesture에 영향을 주지 않도록
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
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
