//
//  FetchOffers.swift
//  Market
//
//  Created by Дмитриев Антон on 10.05.2026.
//

// MARK: - UseCase
protocol FetchOffers {
    func execute(
        from: String,
        to: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    )
}

final class FetchOffersImpl: FetchOffers {
    private let repository: P2PRepository

    init(repository: P2PRepository) {
        self.repository = repository
    }

    func execute(
        from: String,
        to: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        repository.fetchOffers(from: from, to: to) { result in
            switch result {
            case .success(let offers):
                let filtered = offers.filter { $0.seller.reserve > 0 }
                let sorted = filtered.sorted { $0.rate > $1.rate }
                completion(.success(sorted))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

