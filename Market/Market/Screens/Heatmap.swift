//
//  Heatmap.swift
//  Market
//
//  Created by Дмитриев Антон on 27.05.2026.
//

import Foundation
import SwiftUI

struct Currenci: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

struct Heatmap: View {
    let currencies: [Currenci] = [
        Currenci(name: "BTC", color: Color(red: 0, green: 1, blue: 0)),
        Currenci(name: "ETH", color: Color(red: 0.5, green: 0, blue: 0)),
        Currenci(name: "SOL", color: Color(red: 0, green: 0.7, blue: 0)),
        Currenci(name: "XRP", color: Color(red: 1, green: 0, blue: 0)),
        Currenci(name: "DOGE", color: Color(red: 0, green: 0.8, blue: 0)),
        Currenci(name: "BNB", color: Color(red: 0.8, green: 0, blue: 0)),
        Currenci(name: "ADA", color: Color(red: 0, green: 0.9, blue: 0)),
        Currenci(name: "DOT", color: Color(red: 0.7, green: 0, blue: 0)),
        Currenci(name: "TON", color: Color(red: 0, green: 0.5, blue: 0)),
        Currenci(name: "LTC", color: Color(red: 0.9, green: 0, blue: 0)),
        Currenci(name: "RUB", color: Color(red: 0, green: 0.6, blue: 0))
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 3) {
                HStack(spacing: 3) {
                    heatCell(currencies[0], height: 250)

                    VStack(spacing: 3) {
                        heatCell(currencies[1], height: 123)
                        heatCell(currencies[2], height: 123)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 3) {
                    heatCell(currencies[3], height: 120)
                    heatCell(currencies[4], height: 120)
                    heatCell(currencies[5], height: 120)
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 3) {
                    VStack(spacing: 3) {
                        heatCell(currencies[6], height: 120)
                        heatCell(currencies[7], height: 120)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 3) {
                        heatCell(currencies[8], height: 80)
                        heatCell(currencies[9], height: 80)
                        heatCell(currencies[10], height: 80)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func heatCell(_ currency: Currenci, height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(currency.color)
            Text(currency.name)
                .font(.headline.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }
}

#Preview {
    Heatmap()
}
