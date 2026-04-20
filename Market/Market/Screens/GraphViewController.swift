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
    
    private let segmentedControl = UISegmentedControl(items: ["Свечи", "Линия"])
    
    private let lineChartView = LineChartView()
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        makeConstraints()
        generate()
        
        showCandlesMode()
   }
}

private extension GraphViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        
        scrollView.showsHorizontalScrollIndicator = false
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        
        lineChartView.backgroundColor = .secondarySystemBackground
        lineChartView.layer.cornerRadius = 12
        lineChartView.clipsToBounds = true
        
        infoView.numberOfLines = 0
        infoView.textAlignment = .center
        infoView.font = .systemFont(ofSize: 15, weight: .medium)
        
        recommendationView.textAlignment = .center
        recommendationView.font = .boldSystemFont(ofSize: 18)
        recommendationView.textColor = .systemBlue
        
        view.addSubview(segmentedControl)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(infoView)
        view.addSubview(recommendationView)
        
        view.addSubview(lineChartView)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        recommendationView.translatesAutoresizingMaskIntoConstraints = false
    }
}

private extension GraphViewController {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
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
            recommendationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            lineChartView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lineChartView.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
}

private extension GraphViewController {
    func generate() {
        generator.generateCandles(count: 30)
        
        generator.candles.forEach { candle in
            let candleView = CandleView(candle: candle)
            
            candleView.translatesAutoresizingMaskIntoConstraints = false
            candleView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            candleView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            
            addGestures(to: candleView, candle: candle)
            
            stackView.addArrangedSubview(candleView)
        }
        
        lineChartView.prices = generator.candles.map { $0.close }
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

private extension GraphViewController {
    @objc func modeChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            showCandlesMode()
        } else {
            showLineMode()
        }
    }
    
    func showCandlesMode() {
        scrollView.isHidden = false
        infoView.isHidden = false
        recommendationView.isHidden = false
        lineChartView.isHidden = true
    }
    
    func showLineMode() {
        scrollView.isHidden = true
        infoView.isHidden = true
        recommendationView.isHidden = true
        lineChartView.isHidden = false
    }
}
