//
//  CandleView.swift
//  Market
//
//  Created by Дмитриев Антон on 10.04.2026.
//

import Foundation
import UIKit

final class CandleView: UIView {
    private let bodyView = UIView()
    private let tailView = UIView()
    
    private var candle: Candle?
    
    init(candle: Candle) {
        self.candle = candle
        super.init(frame: .zero)
        addSubviews()
        makeConstraints()
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension CandleView {
    func addSubviews() {
        addSubview(tailView)
        addSubview(bodyView)
        
        tailView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func makeConstraints() {
        guard let candle = candle else { return }
        
        let maxOffset = (candle.tailHeight - candle.headHeight) / 2
        let offset = CGFloat.random(in: -maxOffset...maxOffset)
        
        NSLayoutConstraint.activate([
            tailView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tailView.widthAnchor.constraint(equalToConstant: candle.tailWidth),
            tailView.heightAnchor.constraint(equalToConstant: candle.tailHeight),
            tailView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            bodyView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bodyView.widthAnchor.constraint(equalToConstant: candle.headWidth),
            bodyView.heightAnchor.constraint(equalToConstant: candle.headHeight),
            bodyView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset)
        ])
    }
    
    func setUp() {
        guard let candle = candle else { return }
        
        let color = candle.color.uiColor
        
        bodyView.backgroundColor = color
        tailView.backgroundColor = color
    }
}
