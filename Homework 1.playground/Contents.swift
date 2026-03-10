import UIKit

let iterations: Int = 50

var balance: Double = 10000.0
let valutes = ["ruble", "dollar", "euro"]
let minPrice: Double = 50.0
let maxPrice: Double = 100.0

var activePrice: Double? = nil

let valute = valutes.randomElement()!

func decisionBot(price: Double) -> String{
    if price < 65.0 {
        return "buying"
    } else if price > 85.0 {
        return "selling"
    } else {
        return "ignoring"
    }
}

for _ in 1...iterations {
    let currentPrice = Double.random(in: minPrice...maxPrice)
    let decision = decisionBot(price: currentPrice)
    print("\(String(format: "%.2f", currentPrice)) \(valute) - \(decision)")
    
    switch decision {
    case "buying":
        guard activePrice == nil else { continue }
        if balance >= currentPrice {
            activePrice = currentPrice
            balance -= currentPrice
        }
    case "selling":
        if activePrice != nil{
            let purchasePrice = activePrice!
            let income = currentPrice - purchasePrice
            balance += currentPrice
            print("продажа FROM = \(String(format: "%.2f", purchasePrice)) -> TO = \(String(format: "%.2f", currentPrice)), INCOME = +\(String(format: "%.2f", income))")
            activePrice = nil
        }
    default:
        break
    }
    print("Balance: \(String(format: "%.2f", balance))")
}
