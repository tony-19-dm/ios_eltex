//
//  P2PCoordinator.swift
//  Market
//
//  Created by Дмитриев Антон on 09.05.2026.
//

import Foundation
import UIKit

final class P2PCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let wallet: Wallet
    private let from: String
    private let to: String

    init(
        navigationController: UINavigationController,
        wallet: Wallet,
        from: String,
        to: String
    ) {
        self.navigationController = navigationController
        self.wallet = wallet
        self.from = from
        self.to = to
    }

    func start() {
        showOfferList()
    }

    private func showOfferList() {
        let viewModel = P2PViewModel(
            service: P2PService(),
            wallet: wallet,
            from: from,
            to: to
        )

        viewModel.onOfferSelected = { [weak self] offer in
            self?.showSellerInfo(offer: offer)
        }

        let vc = P2PViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    private func showSellerInfo(offer: P2POffer) {
        let viewModel = SellerInfoViewModel(offer: offer)
        let vc = SellerInfoViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
