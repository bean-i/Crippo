//
//  TrendingViewModel.swift
//  Crippo
//
//  Created by 이빈 on 4/20/25.
//

import Foundation
import Combine

@MainActor
final class TrendingViewModel: ViewModelType {
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let favoriteService = FavoriteCoinDataService.shared
    private let coinClient = CoinClient.shared
    
    init() {
        transform()
    }
}

extension TrendingViewModel {
    struct Input {
        let viewAppeared = PassthroughSubject<Void, Never>()
        let coinSelected = PassthroughSubject<String, Never>()
    }
    
    enum Action {
        case viewAppeared
        case coinSelected(String)
    }
    
    struct Output {
        var favoriteCoins: [CoinMarketEntity] = []
        var trendingCoins: [TrendingCoinEntity] = []
        var trendingNFTs: [TrendingNFTEntity] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewAppeared:
            input.viewAppeared.send()
        case .coinSelected(let coinID):
            input.coinSelected.send(coinID)
        }
    }
    
    func transform() {
        input.viewAppeared
            .sink { [weak self] in
                guard let self = self else { return }
                Task {
                    await self.loadData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadData() async {
        output.isLoading = true
        
        // 병렬로 데이터 로드
        async let favoriteTask = loadFavoriteCoins()
        async let trendingTask = loadTrendingData()
        
        // 모든 작업 완료 대기
        do {
            _ = try await (favoriteTask, trendingTask)
            output.isLoading = false
        } catch {
            output.errorMessage = "데이터를 불러오는데 실패했습니다: \(error.localizedDescription)"
            output.isLoading = false
        }
    }
    
    private func loadFavoriteCoins() async {
        // 즐겨찾기된 코인 ID 목록 가져오기
        let favoriteCoins = favoriteService.getAllFavoriteCoins()
        
        // 만약 즐겨찾기가 없으면 빈 배열 설정
        if favoriteCoins.isEmpty {
            output.favoriteCoins = []
            return
        }
        
        // 모든 코인 ID를 쉼표로 구분된 문자열로 변환
        let coinIDs = favoriteCoins.map { $0.coinID }.joined(separator: ",")
        
        do {
            // 단일 API 호출로 모든 즐겨찾기 코인 데이터 가져오기
            let coinDataArray: [CoinMarketResponseDTO] = try await coinClient.coinMarket(id: coinIDs)
            
            // UI 업데이트
            output.favoriteCoins = coinDataArray.map { $0.toEntity() }
        } catch {
            print("Failed to fetch favorite coins data: \(error)")
        }
    }
    
    private func loadTrendingData() async {
        do {
            // 트렌딩 데이터 가져오기
            let trendingData = try await coinClient.fetchTrending()
            
            // 코인 데이터 변환
            output.trendingCoins = trendingData.toEntity().trendingCoins

            // NFT 데이터 변환
            output.trendingNFTs = trendingData.toEntity().trendingNFTs
        } catch {
            print("Failed to fetch trending data: \(error)")
        }
    }
}
