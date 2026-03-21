import UIKit

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
    var iterations: Int { get set }
    var balance: Double { get set }
    var minPrice: Double { get }
    var maxPrice: Double { get }
    var activePrice: Double? { get }
    
    func decisionBot(price: Double, canToSell: Bool) -> String
    func start()
}

extension GenerateTradeProtocol {
    func formatPrice(_ price: Double) -> String {
        return String(format: "%.2f", price)
    }
}

class TradeBot: GenerateTradeProtocol {
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
    
    func start() {
        var valute: Currency = .rubble
        var trade = Trade(currency: valute, price: 0.0, canToSell: false)
        for _ in 1...iterations {
            let currentPrice = Double.random(in: minPrice...maxPrice)
            trade.price = currentPrice
            let decision = decisionBot(price: trade.price, canToSell: trade.canToSell)
            print("\(formatPrice(trade.price)) \(valute) - \(decision)")
            
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
                    print("продажа FROM = \(String(format: "%.2f", purchasePrice)) -> TO = \(formatPrice(trade.price)), INCOME = +\(formatPrice(income))")
                    trade.canToSell = false
                    activePrice = nil
                }
            default:
                break
            }
            print("Balance: \(formatPrice(balance))")
        }
    }
}

var tradeBot = TradeBot()
tradeBot.start()
