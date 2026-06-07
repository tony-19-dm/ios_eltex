//
//  LineChartView.swift
//  Market
//
//  Created by Дмитриев Антон on 20.04.2026.
//

import Foundation
import UIKit

final class LineChartView: UIView {
    private var selectedIndex: Int?
    
    var prices: [Double] = [] {
        didSet {
            selectedIndex = nil
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        isUserInteractionEnabled = true
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard prices.count > 1 else { return }
        
        drawGrid()
        drawLine()
        drawPoints()
        drawSelectedPoint()
        drawPriceLabels()
    }
}

// MARK: - Grid
private extension LineChartView {
    func drawGrid() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(UIColor.systemGray4.cgColor)
        context.setLineWidth(0.5)
        
        let horizontalLines = 5
        let verticalLines = prices.count
        
        // horizontal
        for i in 0...horizontalLines {
            let y = bounds.height / CGFloat(horizontalLines) * CGFloat(i)
            
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: bounds.width, y: y))
        }
        
        // vertical
        for i in 0..<verticalLines {
            let x = bounds.width / CGFloat(verticalLines - 1) * CGFloat(i)
            
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        
        context.strokePath()
    }
}

// MARK: - Line
private extension LineChartView {
    func drawLine() {
        let points = makePoints()
        guard points.count > 1 else { return }
        
        let path = UIBezierPath()
        path.lineWidth = 3
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        
        UIColor.systemMint.setStroke()
        
        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.stroke()
    }
}

// MARK: - Points
private extension LineChartView {
    func drawPoints() {
        let points = makePoints()
        
        for point in points {
            let circle = UIBezierPath(
                arcCenter: point,
                radius: 3,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            
            UIColor.systemMint.setFill()
            circle.fill()
        }
    }
}

// MARK: - Selected Point
private extension LineChartView {
    func drawSelectedPoint() {
        guard let selectedIndex = selectedIndex else { return }
        
        let points = makePoints()
        guard selectedIndex < points.count else { return }
        
        let point = points[selectedIndex]
        
        let circle = UIBezierPath(
            arcCenter: point,
            radius: 7,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        
        UIColor.systemRed.setFill()
        circle.fill()
        
        let price = prices[selectedIndex]
        let text = price.formatToString()
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.label
        ]
        
        text.draw(
            at: CGPoint(x: point.x + 8, y: point.y - 16),
            withAttributes: attrs
        )
    }
}

// MARK: - Price Labels
private extension LineChartView {
    func drawPriceLabels() {
        guard let min = prices.min(), let max = prices.max() else { return }
        
        let step = (max - min) / 4
        
        for i in 0...4 {
            let value = min + step * Double(i)
            
            let y = bounds.height - (bounds.height / 4 * CGFloat(i))
            
            let text = value.formatToString()
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.secondaryLabel
            ]
            
            text.draw(
                at: CGPoint(x: 4, y: y - 8),
                withAttributes: attrs
            )
        }
    }
}

// MARK: - Helpers
private extension LineChartView {
    func makePoints() -> [CGPoint] {
        guard let min = prices.min(), let max = prices.max(), prices.count > 1 else { return [] }
        
        let range = max - min == 0 ? 1 : max - min
        
        return prices.enumerated().map { index, price in
            
            let x = bounds.width / CGFloat(prices.count - 1) * CGFloat(index)
            
            let normalized = (price - min) / range
            
            let y = bounds.height - CGFloat(normalized) * bounds.height
            
            return CGPoint(x: x, y: y)
        }
    }
}

// MARK: - Touch
extension LineChartView {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let points = makePoints()
        
        guard !points.isEmpty else { return }
        
        var nearestIndex = 0
        var nearestDistance = CGFloat.infinity
        
        for (index, point) in points.enumerated() {
            let distance = abs(point.x - location.x)
            
            if distance < nearestDistance {
                nearestDistance = distance
                nearestIndex = index
            }
        }
        
        selectedIndex = nearestIndex
        setNeedsDisplay()
    }
}
