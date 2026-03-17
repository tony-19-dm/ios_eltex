import UIKit

enum Currency: String{
    case rubble = "ruble"
    case dollar = "dollar"
    case euro = "euro"
}

struct Trade {
    let currency: Currency
    var price: Double
    var canToSell: Bool
}

class TradeBot {
    private let iterations: Int = 50

    private var balance: Double = 10000.0
    private let minPrice: Double = 50.0
    private let maxPrice: Double = 100.0

    private var activePrice: Double? = nil
    
    private func decisionBot(price: Double, canToSell: Bool) -> String {
        if !canToSell && price < 65.0 {
            return "buying"
        } else if canToSell && price > 85.0 {
            return "selling"
        } else {
            return "ignoring"
        }
    }
    
    func start() {
        let valute: Currency = .dollar
        var trade = Trade(currency: valute, price: 0.0, canToSell: false)
        for _ in 1...iterations {
            let currentPrice = Double.random(in: minPrice...maxPrice)
            trade.price = currentPrice
            let decision = decisionBot(price: trade.price, canToSell: trade.canToSell)
            print("\(String(format: "%.2f", trade.price)) \(valute) - \(decision)")
            
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
                    print("продажа FROM = \(String(format: "%.2f", purchasePrice)) -> TO = \(String(format: "%.2f", trade.price)), INCOME = +\(String(format: "%.2f", income))")
                    trade.canToSell = false
                    activePrice = nil
                }
            default:
                break
            }
            print("Balance: \(String(format: "%.2f", balance))")
        }
    }
}

var tradeBot = TradeBot()
tradeBot.start()
