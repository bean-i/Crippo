//
//  FavoriteViewModel.swift
//  Crippo
//
//  Created by 이빈 on 4/20/25.
//

import Foundation
import Combine

// MARK: - FavoriteViewModel
@MainActor
final class FavoriteViewModel: ViewModelType {
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let favoriteService = FavoriteCoinDataService.shared
    private let coinClient = CoinClient.shared
    
    init() {
        transform()
    }
}

extension FavoriteViewModel {
    struct Input {
        let viewAppeared = PassthroughSubject<Void, Never>()
        let coinCardTapped = PassthroughSubject<String, Never>()
        let clearSelectedCoin = PassthroughSubject<Void, Never>()
    }
    
    enum Action {
        case viewAppeared
        case coinCardTapped(String)
        case clearSelectedCoin
    }
    
    struct Output {
        var favoriteCoins: [CoinMarketEntity] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var selectedCoinID: String? = nil
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewAppeared:
            input.viewAppeared.send()
        case .coinCardTapped(let coinID):
            output.selectedCoinID = coinID  // 상태 업데이트
            input.coinCardTapped.send(coinID)
        case .clearSelectedCoin:
            output.selectedCoinID = nil  // 선택 해제
            input.clearSelectedCoin.send()
        }
    }
    
    func transform() {
        input.viewAppeared
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.loadFavoriteCoins()
            }
            .store(in: &cancellables)
    }
    
    private func loadFavoriteCoins() {
        output.isLoading = true
        output.errorMessage = nil
        
        // 즐겨찾기된 코인 ID 목록 가져오기
        let favoriteCoins = favoriteService.getAllFavoriteCoins()
        
        // 만약 즐겨찾기가 없으면 일찍 반환
        if favoriteCoins.isEmpty {
            output.isLoading = false
            output.favoriteCoins = []
            return
        }
        
        // 모든 코인 ID를 쉼표로 구분된 문자열로 변환
        let coinIDs = favoriteCoins.map { $0.coinID }.joined(separator: ",")
        
        // 한 번의 API 호출로 모든 코인 데이터 가져오기
        Task {
            do {
                // 단일 API 호출로 모든 즐겨찾기 코인 데이터 가져오기
                let coinDataArray: [CoinMarketResponseDTO] = try await coinClient.coinMarket(id: coinIDs)
                
                // UI 업데이트
                output.favoriteCoins = coinDataArray.map { $0.toEntity() }
                output.isLoading = false
            } catch {
                print("Failed to fetch favorite coins data: \(error)")
                output.errorMessage = "코인 데이터를 가져오는데 실패했습니다: \(error.localizedDescription)"
                output.isLoading = false
            }
        }
    }
}
