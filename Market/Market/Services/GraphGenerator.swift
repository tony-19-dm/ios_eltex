//
//  GraphGenerator.swift
//  Market
//
//  Created by Дмитриев Антон on 10.04.2026.
//

import Foundation
import UIKit

enum PriceMoving: CaseIterable {
    case up
    case down
}

enum CandleColor {
    case green
    case red
}

enum Recommendation: String {
    case buy = "Покупать"
    case sell = "Продавать"
    case hold = "Ждать"
}

struct Candle {
    let open: Double
    let close: Double
    let max: Double
    let min: Double
    
    let headHeight: CGFloat
    let headWidth: CGFloat
    let tailHeight: CGFloat
    let tailWidth: CGFloat
    
    let color: CandleColor
}

final class GraphGenerator {
    private(set) var candles: [Candle] = []
    
    func generateCandles(count: Int = 15) {
        var lastClose: Double = Double.random(in: 10...150)
        
        for _ in 0..<count {
            let open = lastClose
            
            let change = Double.random(in: -20...20)
            let close = max(1, open + change)
            
            let max = max(open, close) + Double.random(in: 0...10)
            let min = min(open, close) - Double.random(in: 0...10)
            
            let color: CandleColor = close >= open ? .green : .red
            
            let bodyHeight = CGFloat(abs(close - open)) * 2 + 10
            let tailHeight = CGFloat(max - min) * 2 + bodyHeight
            
            let candle = Candle(
                open: open,
                close: close,
                max: max,
                min: min,
                
                headHeight: bodyHeight,
                headWidth: 30,
                tailHeight: tailHeight,
                tailWidth: 3,
                
                color: color
            )
            
            candles.append(candle)
            lastClose = close
        }
    }
    
    func makeRecommendation(for candle: Candle) -> Recommendation {
        let diff = candle.close - candle.open
        
        if diff > 10 {
            return .buy
        } else if diff < -10 {
            return .sell
        } else {
            return .hold
        }
    }
}

extension CandleColor {
    var uiColor: UIColor {
        switch self {
        case .green: return .systemGreen
        case .red: return .systemRed
        }
    }
}
