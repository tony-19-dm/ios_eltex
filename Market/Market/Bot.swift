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

struct Trade {
    let currency: Currency
    var price: Double
    var canToSell: Bool
}

protocol GenerateTradeProtocol {
    var valute: Currency { get }
    var iterations: Int { get set }
    var balance: Double { get set }
    var minPrice: Double { get }
    var maxPrice: Double { get }
    var activePrice: Double? { get }
    
    func decisionBot(price: Double, canToSell: Bool) -> String
    func start() -> String
}

extension GenerateTradeProtocol {
    func formatPrice(_ price: Double) -> String {
        return String(format: "%.2f", price)
    }
    
    func returnStringBalance() -> String {
        return formatPrice(balance)
    }
    
    func getValute() -> String {
        return valute.rawValue
    }
}

class TradeBot: GenerateTradeProtocol {
    let valute: Currency = .rubble
    internal var iterations: Int = 50
    internal var balance: Double = 10000.0
    internal let minPrice: Double = 50.0
    internal let maxPrice: Double = 100.0
    internal var activePrice: Double? = nil
    
    func decisionBot(price: Double, canToSell: Bool) -> String {
        if !canToSell && price < 65.0 {
            return "buying"
        } else if canToSell && price > 85.0 {
            return "selling"
        } else {
            return "ignoring"
        }
    }
    
    func start() -> String {
        var trade = Trade(currency: valute, price: 0.0, canToSell: false)
        var history: String = ""
        for _ in 1...iterations {
            let currentPrice = Double.random(in: minPrice...maxPrice)
            trade.price = currentPrice
            let decision = decisionBot(price: trade.price, canToSell: trade.canToSell)
            history += "\(formatPrice(trade.price)) \(valute) - \(decision)\n"
            
            switch decision {
            case "buying":
                guard activePrice == nil else { continue }
                if balance >= trade.price {
                    activePrice = trade.price
                    balance -= trade.price
                    trade.canToSell = true
                }
            case "selling":
                if trade.canToSell && activePrice != nil {
                    let purchasePrice = activePrice!
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

//var tradeBot = TradeBot()
//tradeBot.start()
