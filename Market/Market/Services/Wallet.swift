//
//  Wallet.swift
//  Market
//
//  Created by Дмитриев Антон on 25.04.2026.
//

import Foundation

struct balance {
    let name: String
    var value: Double
    var credit: Double
}

final class Wallet {
    private var balances = [
        balance(name: "USD", value: 10000, credit: 1000),
        balance(name: "BTC", value: 10000, credit: 1000),
        balance(name: "RUB", value: 10000, credit: 1000),
        balance(name: "ETH", value: 10000, credit: 1000)
    ]
    
    private let queue = DispatchQueue(label: "wallet.sync.queue")
    
    func getAllBalances() -> [balance] {
        return queue.sync { balances }
    }
    
    func getBalance(name: String) -> Double {
        return queue.sync {
            if let balance = balances.first(where: { $0.name == name }) {
                return balance.value
            }
            return 0
        }
    }
    
    func updateBalance(from: String, to: String, amount: Double, rate: Double) {
        queue.sync {
            guard let fromIndex = balances.firstIndex(where: { $0.name == from }),
                  let toIndex = balances.firstIndex(where: { $0.name == to }) else { return }
            
            if (balances[fromIndex].value < amount){
                balances[fromIndex].value += balances[fromIndex].credit
            }
            
            balances[fromIndex].value -= amount
            balances[toIndex].value += amount * rate
        }
    }
}
