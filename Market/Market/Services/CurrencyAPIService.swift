//
//  CurrencyAPIService.swift
//  Market
//
//  Created by Дмитриев Антон on 27.04.2026.
//

import Foundation

final class CurrencyAPIService {
    private let network = NetworkService()

    func fetchRate(
        from: String,
        to: String,
        completion: @escaping (Result<Double, NetworkError>) -> Void
    ) {
        let urlString = "https://api.frankfurter.app/latest?from=\(from)&to=\(to)"

        guard let url = URL(string: urlString) else {
            completion(.failure(.parsingError))
            return
        }

        network.request(url: url) { (result: Result<ExchangeRateDTO, NetworkError>) in
            switch result {
            case .success(let dto):

                if let rate = dto.rates[to] {
                    completion(.success(rate))
                } else if let first = dto.rates.values.first {
                    completion(.success(first))
                } else {
                    completion(.failure(.parsingError))
                }

            case .failure:
                completion(.failure(.noInternet))
            }
        }
    }
}
