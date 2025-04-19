//
//  EndPoint.swift
//  Crippo
//
//  Created by 이빈 on 4/18/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol EndPoint {
    var baseURL: String? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }
    var parameters: Encodable { get }
    
    // 응답 에러 처리: 상태 코드와 응답 데이터를 기반으로 에러 생성
    func error(_ statusCode: Int?, data: Data) -> Error
}

extension EndPoint {
    func asURLRequest() throws -> URLRequest {
        
        guard let baseURL,
              var url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        if method == .get {
            let jsonData = try encoder.encode(parameters)
            if let parametersDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                url = url.appendingQueryParameters(parametersDict)
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        return request
    }
}
