//
//  PerformTradeImplTests.swift
//  P2PTests
//
//  Created by Дмитриев Антон on 18.05.2026.
//

import Foundation
import XCTest
@testable import Market

final class PerformTradeImplTests: XCTestCase {
    private var wallet: Wallet!
    private var sut: PerformTradeImpl!
 
    override func setUp() {
        super.setUp()
        wallet = Wallet()
        sut = PerformTradeImpl(wallet: wallet)
    }
 
    // MARK: Validation
    func test_execute_zeroAmount_returnsInvalidInput() {
        var result: TradeResults?
        sut.execute(offer: makeOffer(rate: 90), amount: 0, from: "USD", to: "RUB") { result = $0 }
 
        guard case .failure(let error) = result else { return XCTFail("Expected failure") }
        if case .invalidInput = error { } else { XCTFail("Expected .invalidInput") }
    }
 
    func test_execute_negativeAmount_returnsInvalidInput() {
        var result: TradeResults?
        sut.execute(offer: makeOffer(), amount: -50, from: "USD", to: "RUB") { result = $0 }
 
        guard case .failure(let error) = result else { return XCTFail("Expected failure") }
        if case .invalidInput = error { } else { XCTFail("Expected .invalidInput") }
    }
 
    func test_execute_amountExceedsReserve_returnsInsufficientReserve() {
        let offer = makeOffer(seller: makeSeller(reserve: 100), rate: 90)
        var result: TradeResults?
        sut.execute(offer: offer, amount: 101, from: "USD", to: "RUB") { result = $0 }
 
        guard case .failure(let error) = result else { return XCTFail("Expected failure") }
        if case .insufficientReserve = error { } else { XCTFail("Expected .insufficientReserve") }
    }
 
    func test_execute_amountEqualsReserve_doesNotReturnInsufficientReserve() {
        let offer = makeOffer(seller: makeSeller(reserve: 500), rate: 90)
        var result: TradeResults?
        sut.execute(offer: offer, amount: 500, from: "USD", to: "RUB") { result = $0 }
 
        if case .failure(let e) = result, case .insufficientReserve = e {
            XCTFail("Should not return .insufficientReserve when amount == reserve")
        }
    }
 
    // MARK: Credited calculation
    func test_execute_success_creditedEqualsAmountDividedByRate() {
        let rate = 75.5
        let amount = 150.0
        let offer = makeOffer(seller: makeSeller(reserve: 10000), rate: rate)
        var credited: Double?
 
        for _ in 0..<20 {
            wallet.resetWallet()
            var result: TradeResults?
            sut.execute(offer: offer, amount: amount, from: "USD", to: "RUB") { result = $0 }
            if case .success(let c) = result { credited = c; break }
        }
 
        if let c = credited {
            XCTAssertEqual(c, amount / rate, accuracy: 0.0001)
        }
    }
 
    // MARK: Wallet state after success
    func test_execute_success_deductsFromAndCreditsToCurrency() {
        let rate = 2.0
        let amount = 100.0
        let offer = makeOffer(seller: makeSeller(reserve: 10000), rate: rate)
 
        for _ in 0..<20 {
            wallet.resetWallet()
            let beforeUSD = wallet.getBalance(name: "USD")
            let beforeRUB = wallet.getBalance(name: "RUB")
 
            var result: TradeResults?
            sut.execute(offer: offer, amount: amount, from: "USD", to: "RUB") { result = $0 }
 
            if case .success = result {
                XCTAssertEqual(wallet.getBalance(name: "USD"), beforeUSD - amount, accuracy: 0.001)
                XCTAssertEqual(wallet.getBalance(name: "RUB"), beforeRUB + amount * rate, accuracy: 0.001)
                return
            }
        }
    }
}
 
