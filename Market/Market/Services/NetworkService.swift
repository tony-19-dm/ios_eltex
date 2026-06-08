//
//  NetworkService.swift
//  Market
//
//  Created by Дмитриев Антон on 26.04.2026.
//

import Foundation

enum NetworkError: Error {
    case noInternet
    case parsingError
    case unauthorized
    case serverError(code: Int)
    case unknown
}

struct ExchangeRateDTO: Decodable {
    let rates: [String: Double]
}

final class NetworkService {

    func request<T: Decodable>(
        url: URL,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error as NSError? {
                if error.domain == NSURLErrorDomain {
                    completion(.failure(.noInternet))
                } else {
                    completion(.failure(.unknown))
                }
                return
            }

            guard let http = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }

            if (400...499).contains(http.statusCode) {
                completion(.failure(.parsingError))
                return
            }

            if (500...599).contains(http.statusCode) {
                completion(.failure(.serverError(code: http.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.parsingError))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.parsingError))
            }
        }

        task.resume()
    }
}
