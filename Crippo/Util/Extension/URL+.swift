//
//  URL+.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

extension URL {
    func appendingQueryParameters(_ parameters: [String: Any]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        components.queryItems = queryItems
        return components.url ?? self
    }
}
