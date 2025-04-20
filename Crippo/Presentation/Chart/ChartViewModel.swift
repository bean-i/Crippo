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
    }
    
    // 업데이트 되면,, ~~
    struct Output {
        var results: CoinMarketEntity = CoinMarketEntity.empty
    }
    
    func action(_ action: Action) {
        switch action {
        case .searchQuery(let id):
            input.searchQuery.send(id)
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
    
}

