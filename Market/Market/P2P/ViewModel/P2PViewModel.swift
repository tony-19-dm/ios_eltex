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
        AppLogger.p2p.sellerSelected(sellerName: offer.seller.name, sellerId: offer.seller.id)
        onOfferSelected?(offer)
    }

    func performTrade(offer: P2POffer, amount: Double) {
        AppLogger.p2p.tradeStarted(
            sellerName: offer.seller.name,
            amount: amount,
            from: from,
            to: to
        )
        
        performTrade.execute(
            offer: offer,
            amount: amount,
            from: from,
            to: to
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let credited):
                    AppLogger.p2p.tradeSuccess(
                        sellerName: offer.seller.name,
                        credited: credited,
                        to: self?.to ?? ""
                    )
                    let message = "Вам зачислено: \(String(format: "%.4f", credited))"
                    self?.onTradeSuccess?(message)

                case .failure(let error):
                    AppLogger.p2p.tradeFailure(sellerName: offer.seller.name, amount: amount, err: error)
                    self?.onError?(error.localizedMessage)
                }
            }
        }
    }

    private func loadOffers() {
        AppLogger.p2p.fetchOffersStarted(from: from, to: to)
        fetchOffers.execute(from: from, to: to) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let offers):
                    AppLogger.p2p.fetchOffersSuccess(
                        from: self?.from ?? "",
                        to: self?.to ?? "",
                        count: offers.count
                    )
                    self?.offers = offers
                    self?.onOffersUpdated?()

                case .failure(let error):
                    AppLogger.p2p.fetchOffersFailure(
                        from: self?.from ?? "",
                        to: self?.to ?? "",
                        err: error
                    )
                    self?.onError?(error.localizedMessage)
                }
            }
        }
    }
}
