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
    var onTradeSuccess: ((String) -> Void)?

    var onOfferSelected: ((P2POffer) -> Void)?

    private(set) var offers: [P2POffer] = []

    private let fetchOffers: FetchOffers
    private let performTrade: PerformTrade
    private let from: String
    private let to: String

    init(
        fetchOffers: FetchOffers,
        performTrade: PerformTrade,
        from: String,
        to: String
    ) {
        self.fetchOffers = fetchOffers
        self.performTrade = performTrade
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
        performTrade.execute(
            offer: offer,
            amount: amount,
            from: from,
            to: to
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let credited):
                    let message = "Вам зачислено: \(String(format: "%.4f", credited))"
                    self?.onTradeSuccess?(message)

                case .failure(let error):
                    self?.onError?(error.localizedMessage)
                }
            }
        }
    }

    private func loadOffers() {
        fetchOffers.execute(from: from, to: to) { [weak self] result in
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
