//
//  ContentView.swift
//  Heatmap_market
//
//  Created by Дмитриев Антон on 26.05.2026.
//

import SwiftUI

struct Currency: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

struct ContentView: View {

    let currencies: [Currency] = [
        Currency(name: "BTC", color: Color(red: 0, green: 1, blue: 0)),
        Currency(name: "ETH", color: Color(red: 0.5, green: 0, blue: 0)),
        Currency(name: "SOL", color: Color(red: 0, green: 0.7, blue: 0)),
        Currency(name: "XRP", color: Color(red: 1, green: 0, blue: 0)),
        Currency(name: "DOGE", color: Color(red: 0, green: 0.8, blue: 0)),
        Currency(name: "BNB", color: Color(red: 0.8, green: 0, blue: 0)),
        Currency(name: "ADA", color: Color(red: 0, green: 0.9, blue: 0)),
        Currency(name: "DOT", color: Color(red: 0.7, green: 0, blue: 0)),
        Currency(name: "TON", color: Color(red: 0, green: 0.5, blue: 0)),
        Currency(name: "LTC", color: Color(red: 0.9, green: 0, blue: 0)),
        Currency(name: "RUB", color: Color(red: 0, green: 0.6, blue: 0))
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

    func heatCell(_ currency: Currency, height: CGFloat) -> some View {
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
    ContentView()
}
