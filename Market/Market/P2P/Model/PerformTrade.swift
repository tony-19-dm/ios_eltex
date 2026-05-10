//
//  PerformTrade.swift
//  Market
//
//  Created by Дмитриев Антон on 10.05.2026.
//

// MARK: - UseCase
enum TradeResults {
    case success(credited: Double)
    case failure(NetworkError)
}

protocol PerformTrade {
    func execute(
        offer: P2POffer,
        amount: Double,
        from: String,
        to: String,
        completion: @escaping (TradeResults) -> Void
    )
}

final class PerformTradeImpl: PerformTrade {
    private let wallet: Wallet

    init(wallet: Wallet) {
        self.wallet = wallet
    }

    func execute(
        offer: P2POffer,
        amount: Double,
        from: String,
        to: String,
        completion: @escaping (TradeResults) -> Void
    ) {
        guard amount > 0 else {
            completion(.failure(.invalidInput))
            return
        }

        guard amount <= offer.seller.reserve else {
            completion(.failure(.insufficientReserve))
            return
        }

        let success = Bool.random()

        guard success else {
            completion(.failure(.serverError(code: 500)))
            return
        }

        let credited = amount / offer.rate

        wallet.ensureAccount(name: from)
        wallet.ensureAccount(name: to)
        wallet.updateBalance(from: from, to: to, amount: amount, rate: offer.rate)

        completion(.success(credited: credited))
    }
}
