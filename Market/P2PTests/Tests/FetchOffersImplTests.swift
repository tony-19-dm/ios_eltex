//
//  FetchOffersImplTests.swift
//  P2PTests
//
//  Created by Дмитриев Антон on 18.05.2026.
//

import Foundation
import XCTest
@testable import Market

final class FetchOffersImplTests: XCTestCase {
    private var repository: MockP2PRepository!
    private var sut: FetchOffersImpl!
 
    override func setUp() {
        super.setUp()
        repository = MockP2PRepository()
        sut = FetchOffersImpl(repository: repository)
    }
 
    func test_execute_success_returnsFilteredAndSortedOffers() {
        let seller0 = makeSeller(id: "s0", reserve: 0)
        let seller1 = makeSeller(id: "s1", reserve: 100)
        let seller2 = makeSeller(id: "s2", reserve: 200)
        repository.stubbedOffers = [
            P2POffer(seller: seller0, rate: 95),
            P2POffer(seller: seller2, rate: 88),
            P2POffer(seller: seller1, rate: 92),
        ]
 
        var result: [P2POffer]?
        sut.execute(from: "USD", to: "RUB") { r in
            if case .success(let offers) = r { result = offers }
        }
 
        XCTAssertEqual(result?.count, 2)
        XCTAssertEqual(result?.first?.rate, 92)   // sorted descending
        XCTAssertEqual(result?.last?.rate, 88)
    }
 
    func test_execute_success_excludesOffersWithZeroReserve() {
        repository.stubbedOffers = [
            P2POffer(seller: makeSeller(reserve: 0), rate: 90)
        ]
 
        var result: [P2POffer] = []
        sut.execute(from: "USD", to: "RUB") { r in
            if case .success(let offers) = r { result = offers }
        }
 
        XCTAssertTrue(result.isEmpty)
    }
 
    func test_execute_failure_propagatesError() {
        repository.stubbedError = .noInternet
 
        var receivedError: NetworkError?
        sut.execute(from: "USD", to: "RUB") { r in
            if case .failure(let e) = r { receivedError = e }
        }
 
        if case .noInternet = receivedError { } else {
            XCTFail("Expected .noInternet, got \(String(describing: receivedError))")
        }
    }
 
    func test_execute_success_emptyInput_returnsEmpty() {
        repository.stubbedOffers = []
 
        var result: [P2POffer]?
        sut.execute(from: "USD", to: "RUB") { r in
            if case .success(let offers) = r { result = offers }
        }
 
        XCTAssertEqual(result?.count, 0)
    }
}
