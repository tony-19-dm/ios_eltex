//
//  P2PRepository.swift
//  Market
//
//  Created by Дмитриев Антон on 10.05.2026.
//

import Foundation

protocol P2PRepository {
    func fetchOffers(
        from: String,
        to: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    )
}

final class P2PRepositoryImpl: P2PRepository {
    private let service: P2PService

    init(service: P2PService = P2PService()) {
        self.service = service
    }

    func fetchOffers(
        from: String,
        to: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        service.loadOffers(from: from, to: to, completion: completion)
    }
}

final class MockP2PRepository: P2PRepository {
    var stubbedOffers: [P2POffer] = []
    var stubbedError: NetworkError?

    func fetchOffers(
        from: String,
        to: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        if let error = stubbedError {
            completion(.failure(error))
        } else {
            completion(.success(stubbedOffers))
        }
    }
}
