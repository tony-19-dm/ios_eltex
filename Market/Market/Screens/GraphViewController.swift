//
//  GraphViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 10.04.2026.
//

import Foundation
import UIKit

final class GraphViewController: UIViewController {
    private let generator = GraphGenerator()
       
   private let scrollView = UIScrollView()
   private let stackView = UIStackView()
   
   private let infoView = UILabel()
   private let recommendationView = UILabel()
   
   override func viewDidLoad() {
       super.viewDidLoad()
       
       setupUI()
       makeConstraints()
       generate()
   }
}

private extension GraphViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        scrollView.showsHorizontalScrollIndicator = false
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        infoView.numberOfLines = 0
        infoView.textAlignment = .center
        
        recommendationView.textAlignment = .center
        recommendationView.font = .boldSystemFont(ofSize: 18)
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(infoView)
        view.addSubview(recommendationView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        recommendationView.translatesAutoresizingMaskIntoConstraints = false
    }
}

private extension GraphViewController {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 200),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            infoView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 20),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            recommendationView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 12),
            recommendationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recommendationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

private extension GraphViewController {
    func generate() {
        generator.generateCandles(count: 30)
        
        generator.candles.forEach { candle in
            let view = CandleView(candle: candle)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            addGestures(to: view, candle: candle)
            
            stackView.addArrangedSubview(view)
        }
    }
}

private extension GraphViewController {
    
    func addGestures(to view: UIView, candle: Candle) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let long = UILongPressGestureRecognizer(target: self, action: #selector(handleLong(_:)))
        
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(long)
        
        view.isUserInteractionEnabled = true
        view.tag = generator.candles.firstIndex(where: { $0.open == candle.open }) ?? 0
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let candle = generator.candles[view.tag]
        
        infoView.text = """
        Open: \(candle.open.formatToString())
        Close: \(candle.close.formatToString())
        Max: \(candle.max.formatToString())
        Min: \(candle.min.formatToString())
        """
    }
}

private extension GraphViewController {
    @objc func handleLong(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let view = gesture.view else { return }
        
        let candle = generator.candles[view.tag]
        let rec = generator.makeRecommendation(for: candle)
        
        recommendationView.text = "Совет: \(rec.rawValue)"
    }
}
