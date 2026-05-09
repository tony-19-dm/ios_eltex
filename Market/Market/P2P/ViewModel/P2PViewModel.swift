//
//  P2PViewModel.swift
//  Market
//
//  Created by Дмитриев Антон on 09.05.2026.
//

import Foundation

final class P2PViewModel {
    var onOffersUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onTradeSuccess: (() -> Void)?

    var onOfferSelected: ((P2POffer) -> Void)?

    private(set) var offers: [P2POffer] = []

    private let service: P2PService
    private let wallet: Wallet
    private let from: String
    private let to: String

    init(service: P2PService, wallet: Wallet, from: String, to: String) {
        self.service = service
        self.wallet = wallet
        self.from = from
        self.to = to
    }

    func viewDidLoad() {
        loadOffers()
    }

    func selectOffer(_ offer: P2POffer) {
        onOfferSelected?(offer)
    }

    func performTrade(offer: P2POffer, amount: Double) {
        let success = Bool.random()

        if success {
            wallet.ensureAccount(name: from)
            wallet.ensureAccount(name: to)
            wallet.updateBalance(from: from, to: to, amount: amount, rate: offer.rate)
            onTradeSuccess?()
        } else {
            onError?("Ошибка при выполнении обмена. Попробуйте ещё раз.")
        }
    }

    private func loadOffers() {
        service.loadOffers(from: from, to: to) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let offers):
                    self?.offers = offers
                    self?.onOffersUpdated?()
                case .failure(let error):
                    self?.onError?(error.localizedMessage)
                }
            }
        }
    }
}
