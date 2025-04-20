//
//  ChartViewModel.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation
import Combine

@MainActor
final class ChartViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let favoriteService = FavoriteCoinDataService.shared
    
    init() {
        transform()
    }
}

extension ChartViewModel {
    
    // 뷰에서 인풋
    struct Input {
        let searchQuery = PassthroughSubject<String, Never>()
    }
    
    // Input을 Action과 연결해서 send
    enum Action {
        case searchQuery(String)
        case toggleFavorite(String)
    }
    
    // 업데이트 되면,, ~~
    struct Output {
        var results: CoinMarketEntity = CoinMarketEntity.empty
        var isFavorite: Bool = false
    }
    
    func action(_ action: Action) {
        switch action {
        case .searchQuery(let id):
            input.searchQuery.send(id)
            
        case .toggleFavorite(let id):
            toggleFavorite(coinID: id)
        }
    }
    
    func transform() {
        input.searchQuery
            .sink { [weak self] id in
                guard let self else { return }
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        let response = try await CoinClient.shared.coinMarket(id: id)
                        output.results = response.map { $0.toEntity() }.first ?? CoinMarketEntity.empty
                    } catch {
                        print("❌ ChartViewModel - error: \(error)")
                    }
                }
            }
            .store(in: &cancellables)

    }
    
    // 즐겨찾기 여부 확인 메서드
    func isFavorite(coinID: String) -> Bool {
        return favoriteService.getAllFavoriteCoins().contains(where: { $0.coinID == coinID })
    }
    
    // 즐겨찾기 토글 메서드
    func toggleFavorite(coinID: String) {
        if isFavorite(coinID: coinID) {
            favoriteService.remove(coinID: coinID)
        } else {
            favoriteService.add(coinID: coinID)
        }
        output.isFavorite = isFavorite(coinID: coinID)
    }
    
}

