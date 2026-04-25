//
//  GCDBot.swift
//  Market
//
//  Created by Дмитриев Антон on 25.04.2026.
//

import Foundation

struct TradeResult {
    let botName: String
    let pair: String
    let day: Int
    let income: Double
}

final class GCDBot {
    let name: String
    let first: String
    let second: String
    private let wallet: Wallet
    
    init(name: String, first: String, second: String, wallet: Wallet) {
        self.name = name
        self.first = first
        self.second = second
        self.wallet = wallet
    }
    
    func start(day: Int) -> TradeResult {
        let start = wallet.getBalance(name: second)
        
        let operations = Int.random(in: AppConfig.minOperationsCount...AppConfig.maxOperationsCount)
        
        DispatchQueue.concurrentPerform(iterations: operations) { _ in
            let amount = Double.random(in: 1...10)
            let rate = Double.random(in: 0.1...2.0)
            
            wallet.updateBalance(from: first, to: second, amount: amount, rate: rate)
        }
        
        let end = wallet.getBalance(name: second)
        
        return TradeResult(
            botName: name,
            pair: "\(first)-\(second)",
            day: day,
            income: end - start
        )
    }
}
