//
//  NetworkErrorTests.swift
//  P2PTests
//
//  Created by Дмитриев Антон on 18.05.2026.
//

import Foundation
import XCTest
@testable import Market

final class NetworkErrorTests: XCTestCase {
    func test_noInternet_localizedMessage() {
        XCTAssertEqual(NetworkError.noInternet.localizedMessage, "Нет подключения к интернету")
    }
 
    func test_parsingError_localizedMessage_isNotEmpty() {
        XCTAssertFalse(NetworkError.parsingError.localizedMessage.isEmpty)
    }
 
    func test_unauthorized_localizedMessage_isNotEmpty() {
        XCTAssertFalse(NetworkError.unauthorized.localizedMessage.isEmpty)
    }
 
    func test_invalidInput_localizedMessage() {
        XCTAssertEqual(NetworkError.invalidInput.localizedMessage, "Введите корректную сумму")
    }
 
    func test_insufficientReserve_localizedMessage() {
        XCTAssertEqual(NetworkError.insufficientReserve.localizedMessage, "Сумма превышает резерв продавца")
    }
 
    func test_serverError_localizedMessage_isNotEmpty() {
        XCTAssertFalse(NetworkError.serverError(code: 503).localizedMessage.isEmpty)
    }
 
    func test_unknown_localizedMessage_isNotEmpty() {
        XCTAssertFalse(NetworkError.unknown.localizedMessage.isEmpty)
    }
}
