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
    private let credit: Double = 1000
    
    private var balances = [
        balance(name: "USD", value: 10000, credit: 0),
        balance(name: "BTC", value: 10000, credit: 0),
        balance(name: "RUB", value: 10000, credit: 0),
        balance(name: "ETH", value: 10000, credit: 0)
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
                balances[fromIndex].value += credit
                balances[fromIndex].credit += credit
            }
            
            balances[fromIndex].value -= amount
            balances[toIndex].value += amount * rate
        }
    }
    
    func resetWallet() {
        queue.sync {
            for index in balances.indices {
                balances[index].credit = 0
                balances[index].value = 10000
            }
        }
    }
}
