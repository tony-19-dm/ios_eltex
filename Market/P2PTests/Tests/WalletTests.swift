//
//  WalletTests.swift
//  P2PTests
//
//  Created by Дмитриев Антон on 18.05.2026.
//

import Foundation
import XCTest
@testable import Market

final class WalletTests: XCTestCase {
    private var sut: Wallet!
 
    override func setUp() {
        super.setUp()
        sut = Wallet()
    }
 
    func test_getBalance_returnsDefaultForPreloadedCurrency() {
        XCTAssertEqual(sut.getBalance(name: "USD"), 10000)
    }
 
    func test_getBalance_returnsZeroForUnknownCurrency() {
        XCTAssertEqual(sut.getBalance(name: "XYZ"), 0)
    }
 
    func test_ensureAccount_createsNewAccountWithDefaultBalance() {
        sut.ensureAccount(name: "JPY")
        XCTAssertEqual(sut.getBalance(name: "JPY"), 10000)
    }
 
    func test_ensureAccount_doesNotResetExistingAccount() {
        sut.updateBalance(from: "USD", to: "RUB", amount: 500, rate: 1)
        let balanceBefore = sut.getBalance(name: "USD")
        sut.ensureAccount(name: "USD")
        XCTAssertEqual(sut.getBalance(name: "USD"), balanceBefore)
    }
 
    func test_updateBalance_decreasesFromAndIncreasesTo() {
        let beforeUSD = sut.getBalance(name: "USD")
        let beforeRUB = sut.getBalance(name: "RUB")
 
        sut.updateBalance(from: "USD", to: "RUB", amount: 100, rate: 90)
 
        XCTAssertEqual(sut.getBalance(name: "USD"), beforeUSD - 100, accuracy: 0.001)
        XCTAssertEqual(sut.getBalance(name: "RUB"), beforeRUB + 9000, accuracy: 0.001)
    }
 
    func test_updateBalance_appliesCreditWhenFromBalanceInsufficient() {
        // Drain USD to 0
        sut.updateBalance(from: "USD", to: "RUB", amount: 10000, rate: 1)
        XCTAssertEqual(sut.getBalance(name: "USD"), 0)
 
        // Credit (+1000) should be added, then 500 deducted → 500 remaining
        sut.updateBalance(from: "USD", to: "RUB", amount: 500, rate: 1)
        XCTAssertEqual(sut.getBalance(name: "USD"), 500, accuracy: 0.001)
    }
 
    func test_resetWallet_restoresDefaultBalancesAndZerosCredit() {
        sut.updateBalance(from: "USD", to: "RUB", amount: 5000, rate: 90)
        sut.resetWallet()
 
        XCTAssertEqual(sut.getBalance(name: "USD"), 10000)
        XCTAssertEqual(sut.getBalance(name: "RUB"), 10000)
    }
 
    func test_getAllBalances_containsAllPreloadedCurrencies() {
        let names = sut.getAllBalances().map { $0.name }
        XCTAssertTrue(names.contains("USD"))
        XCTAssertTrue(names.contains("BTC"))
        XCTAssertTrue(names.contains("RUB"))
        XCTAssertTrue(names.contains("ETH"))
    }
 
    func test_concurrentAccess_doesNotCrash() {
        let exp = XCTestExpectation(description: "concurrent")
        exp.expectedFulfillmentCount = 20
 
        for _ in 0..<20 {
            DispatchQueue.global().async {
                self.sut.updateBalance(from: "USD", to: "RUB", amount: 1, rate: 1)
                exp.fulfill()
            }
        }
 
        wait(for: [exp], timeout: 3.0)
    }
}
