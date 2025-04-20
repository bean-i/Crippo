////
////  SearchView.swift
////  Crippo
////
////  Created by 이빈 on 4/18/25.
////
//
//import SwiftUI
//
//struct SearchView: View {
//    
//    @StateObject private var viewModel = SearchViewModel()
//    
//    @State private var path: [CoinSearchEntity] = []
//    @State private var query = ""
////    @State private var results: [SearchCoin] = MockData.searchCoins
//    @State private var favorites: Set<String> = []
//
//    var body: some View {
//        NavigationStack(path: $path) {
//            List {
//                ForEach(viewModel.output.results) { coin in
//                    SearchResultRow(
//                        coin: coin,
//                        query: query
//                    )
//                    .listRowSeparator(.hidden)
//                }
//            }
//            .listStyle(.plain)
//            .searchable(text: $query, prompt: "코인 검색")
//            .onSubmit(of: .search) {
//                print("\(query) 검색 ㄱ ㄱ")
//                viewModel.action(.searchQuery(query))
//            }
//            .navigationTitle("Search")
//            .navigationDestination(for: CoinSearchEntity.self) { coin in
//                ChartView(coinID: coin.coinID)
////                ChartView(coinID: coin)
////                if let market = MockData.marketCoins.first(where: { $0.id == coin.id }) {
////                    ChartView(coin: market)
////                } else {
////                    Text("데이터 없음")
////                }
//            }
//        }
//    }
//}
//
//// MARK: - 코인 검색 결과 Row
//private struct SearchResultRow: View {
//    let coin: CoinSearchEntity
//    let query: String
//    let isFavorited: Bool = false
//    //    let onSelect: () -> Void
//    //    let onFavorite: () -> Void
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            // 썸네일
//            AsyncImage(url: URL(string: coin.thumb)) { img in
//                img.resizable()
//                    .aspectRatio(1, contentMode: .fit)
//            } placeholder: {
//                Color.gray.opacity(0.2)
//            }
//            .frame(width: 32, height: 32)
//            .cornerRadius(4)
//            
//            // 이름/심볼
//            VStack(alignment: .leading, spacing: 2) {
//                HighlightedText(fullText: coin.name, highlight: query)
//                    .font(.body)
//                Text(coin.symbol)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//            // 별 버튼
//            Button {
//                print("저장 버튼 탭")
//            } label: {
//                Image(systemName: isFavorited ? "star.fill" : "star")
//                    .foregroundColor(.point)
//            }
//        }
//        .padding(.vertical, 8)
//        .contentShape(Rectangle())
//    }
//    
//}
//
//struct HighlightedText: View {
//    let fullText: String
//    let highlight: String
//    
//    var body: some View {
//        // 대소문자 구분 없이 매칭
//        if let range = fullText.lowercased().range(of: highlight.lowercased()), !highlight.isEmpty {
//            let start = String(fullText[..<range.lowerBound])
//            let match = String(fullText[range])
//            let end   = String(fullText[range.upperBound...])
//            
//            HStack(spacing: 0) {
//                Text(start)
//                Text(match)
//                    .foregroundColor(.point)
//                Text(end)
//            }
//        } else {
//            Text(fullText)
//        }
//    }
//}
//
//#Preview {
//    SearchView()
//}
import SwiftUI

struct SearchView: View {
    
    @StateObject private var viewModel = SearchViewModel()
    
    @State private var path: [CoinSearchEntity] = []
    @State private var query = ""
    @State private var favorites: Set<String> = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(viewModel.output.results, id: \.id) { coin in
                    SearchResultRow(
                        coin: coin,
                        query: query,
                        isFavorited: favorites.contains(coin.coinID)
                    )
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())  // 전체 영역을 탭 가능하게 함
                    .onTapGesture {
                        // 클릭 시 path에 코인 추가하여 네비게이션
                        path.append(coin)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $query, prompt: "코인 검색")
            .onSubmit(of: .search) {
                print("\(query) 검색 ㄱ ㄱ")
                viewModel.action(.searchQuery(query))
            }
            .navigationTitle("Search")
            .navigationDestination(for: CoinSearchEntity.self) { coin in
                ChartView(coinID: coin.coinID)  // ID가 String일 경우 변환
            }
        }
    }
}

// MARK: - 코인 검색 결과 Row
private struct SearchResultRow: View {
    let coin: CoinSearchEntity
    let query: String
    let isFavorited: Bool
    
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
                print("저장 버튼 탭")
            } label: {
                Image(systemName: isFavorited ? "star.fill" : "star")
                    .foregroundColor(.point)
            }
            .buttonStyle(PlainButtonStyle())  // 버튼이 부모 onTapGesture에 영향을 주지 않도록
        }
        .padding(.vertical, 8)
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
