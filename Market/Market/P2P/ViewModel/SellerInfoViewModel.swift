//
//  SellerInfoViewModel.swift
//  Market
//
//  Created by Дмитриев Антон on 09.05.2026.
//

import Foundation

final class SellerInfoViewModel {
    let sellerName: String
    let sellerId: String
    let reserve: String
    let rate: String
    let rating: String
    let completedTrades: String
    let memberSince: String

    init(offer: P2POffer) {
        sellerName = offer.seller.name
        sellerId = offer.seller.id
        reserve = String(format: "%.2f", offer.seller.reserve)
        rate = String(format: "%.4f", offer.rate)

        rating = String(format: "%.1f", Double.random(in: 4.0...5.0))
        completedTrades = "\(Int.random(in: 10...500))"
        memberSince = "2023"
    }
}
