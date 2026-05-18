//
//  MockPerformTrade.swift
//  P2PTests
//
//  Created by Дмитриев Антон on 18.05.2026.
//

import Foundation
@testable import Market

final class MockPerformTrade: PerformTrade {
    var stubbedResult: TradeResults = .success(credited: 1.0)
    private(set) var executeCallCount = 0
    private(set) var lastOffer: P2POffer?
    private(set) var lastAmount: Double?
    private(set) var lastFrom: String?
    private(set) var lastTo: String?
 
    func execute(
        offer: P2POffer,
        amount: Double,
        from: String,
        to: String,
        completion: @escaping (TradeResults) -> Void
    ) {
        executeCallCount += 1
        lastOffer = offer
        lastAmount = amount
        lastFrom = from
        lastTo = to
        completion(stubbedResult)
    }
}

func makeSeller(
    id: String = "seller-1",
    name: String = "Alice",
    reserve: Double = 5000
) -> Seller {
    Seller(id: id, name: name, reserve: reserve)
}

func makeOffer(
    seller: Seller? = nil,
    rate: Double = 90.0
) -> P2POffer {
    P2POffer(seller: seller ?? makeSeller(), rate: rate)
}
