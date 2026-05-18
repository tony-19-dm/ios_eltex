//
//  MockFetchOffers.swift
//  P2PTests
//
//  Created by Дмитриев Антон on 18.05.2026.
//

import Foundation
@testable import Market

final class MockFetchOffers: FetchOffers {
    var stubbedResult: Result<[P2POffer], NetworkError> = .success([])
    private(set) var executeCallCount = 0
    private(set) var lastFrom: String?
    private(set) var lastTo: String?
 
    func execute(
        from: String,
        to: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        executeCallCount += 1
        lastFrom = from
        lastTo = to
        completion(stubbedResult)
    }
}
