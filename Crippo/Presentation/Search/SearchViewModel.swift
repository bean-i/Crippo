//
//  SearchViewModel.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let favoriteService = FavoriteCoinDataService.shared
    
    init() {
        transform()
    }
}

extension SearchViewModel {
    
    // 뷰에서 인풋
    struct Input {
        let searchQuery = CurrentValueSubject<String, Never>("")
        let coinRowTapped = PassthroughSubject<Void, Never>()
        let toggleFavorite = PassthroughSubject<String, Never>()
    }
    
    // Input을 Action과 연결해서 send
    enum Action {
        case searchQuery(String)
        case coinRowTapped
        case toggleFavorite(String)
    }
    
    // 업데이트 되면,, ~~
    struct Output {
        var results: [CoinSearchEntity] = []
        var favoriteIDs: Set<String> = []
        var toastMessage: String? = nil
        var showToast: Bool = false
    }
    
    func action(_ action: Action) {
        switch action {
        case .searchQuery(let query):
            input.searchQuery.send(query)
        case .coinRowTapped:
            print("코인 선택 됨.")
        case .toggleFavorite(let coinID):
            toggleFavorite(coinID: coinID)
        }
    }
    
    func transform() {
        input.searchQuery
            .sink { [weak self] query in
                guard let self else { return }
                Task {  [weak self] in
                    guard let self else { return }
                    do {
                        let response = try await CoinClient.shared.searchCoin(query: query)
                        output.results = response.coins.map { $0.toEntity() }
                        updateFavoriteStatus()
                    } catch {
                        // 에러 처리 필요
                    }
                }
            }
            .store(in: &cancellables)

        input.toggleFavorite
            .sink { [weak self] coinID in
                guard let self else { return }
                self.toggleFavorite(coinID: coinID)
            }
            .store(in: &cancellables)
    }
    
    // 코인 ID가 즐겨찾기인지 확인
    func isFavorite(coinID: String) -> Bool {
        return favoriteService.getAllFavoriteCoins().contains(where: { $0.coinID == coinID })
    }
    
    // 즐겨찾기 토글
    func toggleFavorite(coinID: String) {
        if isFavorite(coinID: coinID) {
            // 제거
            let result = favoriteService.remove(coinID: coinID)
            if result == .removed {
                showToastMessage("お気に入りから削除しました。")
            }
        } else {
            // 추가
            let result = favoriteService.add(coinID: coinID)
            switch result {
            case .added:
                showToastMessage("お気に入りに追加しました。")
            case .limitReached:
                showToastMessage("お気に入りは最大10件まで登録できます。")
            default:
                break
            }
        }
        // 결과 업데이트
        updateFavoriteStatus()
    }
    
    // 모든 결과의 즐겨찾기 상태 업데이트
    func updateFavoriteStatus() {
        output.favoriteIDs = Set(favoriteService.getAllFavoriteCoins().map { $0.coinID })
    }
    
    // 토스트 메시지 표시
    private func showToastMessage(_ message: String) {
        output.toastMessage = message
        output.showToast = true
    }
}
