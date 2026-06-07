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

enum Operations: CaseIterable {
    case buy
    case sell
}

final class GCDBot {
    let name: String
    let first: String
    let second: String
    
    private let wallet: Wallet
    
    init(
        name: String,
        first: String,
        second: String,
        wallet: Wallet
    ) {
        self.name = name
        self.first = first
        self.second = second
        self.wallet = wallet
    }
}

extension GCDBot {
    func start(day: Int) -> TradeResult {
        let startBalance = wallet.getBalance(name: second)

        let countOperations = Int.random(in: AppConfig.minOperationsCount...AppConfig.maxOperationsCount)

        for _ in 0..<countOperations {
            guard let opration = Operations.allCases.randomElement() else { continue }

            let amount = Double.random(in: 1...10)
            let rate = Double.random(in: 0.5...2.0)
            
            switch opration {
            case .buy:
                wallet.updateBalance(
                    from: first,
                    to: second,
                    amount: amount,
                    rate: rate
                )
            case .sell:
                wallet.updateBalance(
                    from: second,
                    to: first,
                    amount: amount,
                    rate: 1 / rate
                )
            }
        }

        let endBalance = wallet.getBalance(name: second)

        return TradeResult(
            botName: name,
            pair: "\(first)-\(second)",
            day: day,
            income: endBalance - startBalance
        )
    }
}
