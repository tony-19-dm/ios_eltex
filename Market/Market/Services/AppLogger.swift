//
//  AppLogger.swift
//  Market
//
//  Created by Дмитриев Антон on 19.05.2026.
//

import Foundation
import OSLog

struct AppLogger {
    static let subSystem = Bundle.main.bundleIdentifier ?? ""
    
    static let auth = Logger(subsystem: AppLogger.subSystem, category: "auth")
    static let p2p = Logger(subsystem: AppLogger.subSystem, category: "p2p")
    static let network = Logger(subsystem: subSystem, category: "network")
}

enum AuthValidationFailure {
    case loginTooShort
    case loginContainsSpaces
    case passwordTooShort
    case passwordContainsSpaces
 
    var description: String {
        switch self {
        case .loginTooShort:
            return "логин короче 3 символов"
        case .loginContainsSpaces:
            return"логин содержит пробелы"
        case .passwordTooShort:
            return "пароль короче 6 символов"
        case .passwordContainsSpaces:
            return "пароль содержит пробелы"
        }
    }
}

// MARK: - Auth
extension Logger {
    func loginAttempt(login: String) {
        info("Попытка входа: login='\(login, privacy: .public)'")
    }
 
    func loginSuccess(login: String) {
        info("Вход выполнен: login='\(login, privacy: .public)'")
    }
 
    func loginFailure(login: String) {
        warning("Неверный логин или пароль: login='\(login, privacy: .public)'")
    }
 
    func registerSuccess(login: String) {
        info("Регистрация выполнена: login='\(login, privacy: .public)'")
    }
 
    func validationFailed(login: String, reason: AuthValidationFailure) {
        warning("Валидация не пройдена: login='\(login, privacy: .public)', причина='\(reason.description, privacy: .public)'")
    }
}

// MARK: - Network
extension Logger {
    func requestStarted(url: URL) {
        info("Запрос: \(url.absoluteString, privacy: .public)")
    }
 
    func requestSuccess(url: URL, statusCode: Int) {
        info("Ответ: \(url.absoluteString, privacy: .public), status=\(statusCode)")
    }
 
    func requestFailure(url: URL, err: NetworkError) {
        error("Ошибка запроса: \(url.absoluteString, privacy: .public), error='\(err.localizedMessage, privacy: .public)'")
    }
 
    func requestParsingFailure(url: URL) {
        error("Ошибка парсинга: \(url.absoluteString, privacy: .public)")
    }
}

// MARK: - P2P helpers
extension Logger {
    func fetchOffersStarted(from: String, to: String) {
        info("Загрузка офферов: \(from, privacy: .public) → \(to, privacy: .public)")
    }
 
    func fetchOffersSuccess(from: String, to: String, count: Int) {
        info("Офферы загружены: \(from, privacy: .public) → \(to, privacy: .public), count=\(count)")
    }
 
    func fetchOffersFailure(from: String, to: String, err: NetworkError) {
        error("Ошибка загрузки офферов: \(from, privacy: .public) → \(to, privacy: .public), error='\(err.localizedMessage, privacy: .public)'")
    }
 
    func tradeStarted(sellerName: String, amount: Double, from: String, to: String) {
        info("Начало сделки: seller='\(sellerName, privacy: .public)', amount=\(amount), \(from, privacy: .public) → \(to, privacy: .public)")
    }
 
    func tradeSuccess(sellerName: String, credited: Double, to: String) {
        info("Сделка выполнена: seller='\(sellerName, privacy: .public)', credited=\(credited) \(to, privacy: .public)")
    }
 
    func tradeFailure(sellerName: String, amount: Double, err: NetworkError) {
        error("Ошибка сделки: seller='\(sellerName, privacy: .public)', amount=\(amount), error='\(err.localizedMessage, privacy: .public)'")
    }
 
    func sellerSelected(sellerName: String, sellerId: String) {
        info("Выбран продавец: name='\(sellerName, privacy: .public)', id='\(sellerId, privacy: .public)'")
    }
}
