//
//  NetworkProvider.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

struct NetworkProvider<E: EndPoint>: Sendable {
    
    func request<T: Decodable>(_ endpoint: E) async throws -> T {

        let request = try endpoint.asURLRequest()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw endpoint.error(http.statusCode, data: data)
        }

        return try endpoint.decoder.decode(T.self, from: data)
    }
    
}
