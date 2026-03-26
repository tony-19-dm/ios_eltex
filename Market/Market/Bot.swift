//
//  Bot.swift
//  Market
//
//  Created by Дмитриев Антон on 19.03.2026.
//

import Foundation

enum Currency: String {
    case rubble = "ruble"
    case dollar = "dollar"
    case euro = "euro"
}

enum Decision: String {
    case buying = "buying"
    case selling = "selling"
    case ignoring = "ignoring"
}

struct Trade {
    let currency: Currency
    var price: Double
    var canToSell: Bool
}

protocol GenerateTradeProtocol {
    var currency: Currency { get }
    var iterations: Int { get set }
    var balance: Double { get set }
    var minPrice: Double { get }
    var maxPrice: Double { get }
    var activePrice: Double? { get }
    
    func decisionBot(price: Double, canToSell: Bool) -> Decision
    func start() -> String
}

extension GenerateTradeProtocol {
    func formatPrice(_ price: Double) -> String {
        return String(format: "%.2f", price)
    }
    
    func returnStringBalance() -> String {
        return formatPrice(balance)
    }
    
    func getCurrency() -> String {
        return currency.rawValue
    }
}

final class TradeBot: GenerateTradeProtocol {
    let currency: Currency = .rubble
    var iterations: Int = 50
    var balance: Double = 10000.0
    let minPrice: Double = 50.0
    let maxPrice: Double = 100.0
    var activePrice: Double? = nil
    
    func decisionBot(price: Double, canToSell: Bool) -> Decision {
        if !canToSell && price < 65.0 {
            return .buying
        } else if canToSell && price > 85.0 {
            return .selling
        } else {
            return .ignoring
        }
    }
    
    func start() -> String {
        var trade = Trade(currency: currency, price: 0.0, canToSell: false)
        var history: String = ""
        for _ in 0...iterations {
            let currentPrice = Double.random(in: minPrice...maxPrice)
            trade.price = currentPrice
            let decision = decisionBot(price: trade.price, canToSell: trade.canToSell)
            history += "\(formatPrice(trade.price)) \(currency) - \(decision.rawValue)\n"
            
            switch decision {
            case .buying:
                guard activePrice == nil else { continue }
                if balance >= trade.price {
                    activePrice = trade.price
                    balance -= trade.price
                    trade.canToSell = true
                }
            case .selling:
                if trade.canToSell, let activePriceUnwrapped = activePrice {
                    let purchasePrice = activePriceUnwrapped
                    let income = trade.price - purchasePrice
                    balance += trade.price
                    history += ("ПРОДАЖА:\n")
                    history += ("FROM = \(String(format: "%.2f", purchasePrice)) -> TO = \(formatPrice(trade.price)), INCOME = +\(formatPrice(income))\n")
                    trade.canToSell = false
                    activePrice = nil
                }
            default:
                break
            }
        }
        trade.canToSell = false
        activePrice = nil
        return history
    }
}
