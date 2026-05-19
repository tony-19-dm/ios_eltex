//
//  P2PViewModelTests.swift
//  P2PTests
//
//  Created by Дмитриев Антон on 18.05.2026.
//

import Foundation
import XCTest
@testable import Market

final class P2PViewModelTests: XCTestCase {
    private var fetchOffers: MockFetchOffers!
    private var performTrade: MockPerformTrade!
    private var sut: P2PViewModel!

    override func setUp() {
        super.setUp()
        fetchOffers = MockFetchOffers()
        performTrade = MockPerformTrade()
        sut = P2PViewModel(
            fetchOffers: fetchOffers,
            performTrade: performTrade,
            from: "USD",
            to: "RUB"
        )
    }

    override func tearDown() {
        sut = nil
        fetchOffers = nil
        performTrade = nil
        super.tearDown()
    }

    // MARK: - viewDidLoad
    func test_viewDidLoad_callsFetchOffersWithCorrectCurrencies() {
        sut.viewDidLoad()

        XCTAssertEqual(fetchOffers.executeCallCount, 1)
        XCTAssertEqual(fetchOffers.lastFrom, "USD")
        XCTAssertEqual(fetchOffers.lastTo, "RUB")
    }

    func test_viewDidLoad_onSuccess_populatesOffers() {
        fetchOffers.stubbedResult = .success([makeOffer(rate: 90), makeOffer(rate: 91)])

        let exp = expectation(description: "onOffersUpdated")
        sut.onOffersUpdated = { exp.fulfill() }

        sut.viewDidLoad()
        waitForExpectations(timeout: 1)

        XCTAssertEqual(sut.offers.count, 2)
    }

    func test_viewDidLoad_onFailure_callsOnError() {
        fetchOffers.stubbedResult = .failure(.noInternet)

        let exp = expectation(description: "onError")
        var errorMessage: String?
        sut.onError = {
            errorMessage = $0
            exp.fulfill()
        }

        sut.viewDidLoad()
        waitForExpectations(timeout: 1)

        XCTAssertEqual(errorMessage, NetworkError.noInternet.localizedMessage)
    }

    func test_viewDidLoad_onSuccess_offersAreEmptyWhenNoneReturned() {
        fetchOffers.stubbedResult = .success([])

        let exp = expectation(description: "onOffersUpdated")
        sut.onOffersUpdated = { exp.fulfill() }

        sut.viewDidLoad()
        waitForExpectations(timeout: 1)

        XCTAssertTrue(sut.offers.isEmpty)
    }

    // MARK: - selectOffer
    func test_selectOffer_triggersOnOfferSelected() {
        let offer = makeOffer()
        var selectedOffer: P2POffer?
        sut.onOfferSelected = { selectedOffer = $0 }

        sut.selectOffer(offer)

        XCTAssertEqual(selectedOffer?.seller.id, offer.seller.id)
    }

    func test_selectOffer_doesNotCrashWhenCallbackIsNil() {
        sut.onOfferSelected = nil
        XCTAssertNoThrow(sut.selectOffer(makeOffer()))
    }

    // MARK: - performTrade – success
    func test_performTrade_success_callsOnTradeSuccess() {
        performTrade.stubbedResult = .success(credited: 111.1234)

        let exp = expectation(description: "onTradeSuccess")
        var successMessage: String?
        sut.onTradeSuccess = {
            successMessage = $0
            exp.fulfill()
        }

        sut.performTrade(offer: makeOffer(), amount: 100)
        waitForExpectations(timeout: 1)

        XCTAssertNotNil(successMessage)
        XCTAssertTrue(successMessage!.contains("111.1234"))
    }

    func test_performTrade_success_passesCorrectParametersToUseCase() {
        let offer = makeOffer(rate: 88.0)

        let exp = expectation(description: "onTradeSuccess")
        sut.onTradeSuccess = { _ in exp.fulfill() }

        sut.performTrade(offer: offer, amount: 250)
        waitForExpectations(timeout: 1)

        XCTAssertEqual(performTrade.lastOffer?.rate, 88.0)
        XCTAssertEqual(performTrade.lastAmount, 250)
        XCTAssertEqual(performTrade.lastFrom, "USD")
        XCTAssertEqual(performTrade.lastTo, "RUB")
    }

    // MARK: - performTrade – failure
    func test_performTrade_failure_insufficientReserve_callsOnError() {
        performTrade.stubbedResult = .failure(.insufficientReserve)

        let exp = expectation(description: "onError")
        var errorMessage: String?
        sut.onError = {
            errorMessage = $0
            exp.fulfill()
        }

        sut.performTrade(offer: makeOffer(), amount: 99999)
        waitForExpectations(timeout: 1)

        XCTAssertEqual(errorMessage, NetworkError.insufficientReserve.localizedMessage)
    }

    func test_performTrade_failure_invalidInput_callsOnError() {
        performTrade.stubbedResult = .failure(.invalidInput)

        let exp = expectation(description: "onError")
        var errorMessage: String?
        sut.onError = {
            errorMessage = $0
            exp.fulfill()
        }

        sut.performTrade(offer: makeOffer(), amount: -1)
        waitForExpectations(timeout: 1)

        XCTAssertEqual(errorMessage, NetworkError.invalidInput.localizedMessage)
    }

    func test_performTrade_failure_serverError_callsOnError() {
        performTrade.stubbedResult = .failure(.serverError(code: 500))

        let exp = expectation(description: "onError")
        var errorMessage: String?
        sut.onError = {
            errorMessage = $0
            exp.fulfill()
        }

        sut.performTrade(offer: makeOffer(), amount: 50)
        waitForExpectations(timeout: 1)

        XCTAssertNotNil(errorMessage)
    }

    func test_performTrade_callsExecuteExactlyOnce() {
        let exp = expectation(description: "onTradeSuccess")
        sut.onTradeSuccess = { _ in exp.fulfill() }

        sut.performTrade(offer: makeOffer(), amount: 10)
        waitForExpectations(timeout: 1)

        XCTAssertEqual(performTrade.executeCallCount, 1)
    }
}
