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
    
    init() {
        transform()
    }
}

extension SearchViewModel {
    
    // 뷰에서 인풋
    struct Input {
        let searchQuery = CurrentValueSubject<String, Never>("")
        let coinRowTapped = PassthroughSubject<Void, Never>()
        let saveButtonTapped = PassthroughSubject<Void, Never>()
    }
    
    // Input을 Action과 연결해서 send
    enum Action {
        case searchQuery(String)
        case coinRowTapped
        case saveButtonTapped
    }
    
    // 업데이트 되면,, ~~
    struct Output {
        var results: [CoinSearchEntity] = []
    }
    
    func action(_ action: Action) {
        switch action {
        case .searchQuery(let query):
            input.searchQuery.send(query)
        case .coinRowTapped:
            print("as")
        case .saveButtonTapped:
            print("r")
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
                        print("***", response.coins)
                    } catch {
                        // 에러 처리 필욕
                    }
                }
            }
            .store(in: &cancellables)

    }
    
}

