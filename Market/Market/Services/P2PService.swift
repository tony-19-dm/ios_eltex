//
//  P2PService.swift
//  Market
//
//  Created by Дмитриев Антон on 27.04.2026.
//

import Foundation

struct Seller {
    let id: String
    let name: String
    let reserve: Double
}

struct P2POffer {
    let seller: Seller
    let rate: Double
}

final class P2PService {
    private let api = CurrencyAPIService()

    func loadOffers(
        from: String,
        to: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        api.fetchRate(from: from, to: to) { result in
            switch result {
            case .success(let baseRate):
                let sellers = (1...10).map { i in
                    Seller(
                        id: UUID().uuidString,
                        name: "Seller \(i)",
                        reserve: Double.random(in: 1000...10000)
                    )
                }

                let offers = sellers.map { seller in
                    let spread = Double.random(in: -0.05...0.03)
                    return P2POffer(
                        seller: seller,
                        rate: baseRate * (1 + spread)
                    )
                }
                .sorted { $0.rate > $1.rate }

                completion(.success(offers))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
