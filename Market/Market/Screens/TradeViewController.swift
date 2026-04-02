//
//  TradeViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 02.04.2026.
//

import Foundation
import UIKit

final class TradeViewController: UIViewController {
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        return layout
    }()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    private let firstCurrencyButton = UIButton()
    private let secondCurrencyButton = UIButton()
    private let rateLabel = UILabel()
    
    private let currencyService = CurrencyService()
    
    private let filterControl = UISegmentedControl(items: ["All", "Fiat", "Crypto"])
    
    private let amountTextField = UITextField()
    private let resultLabel = UILabel()
    private let timerLabel = UILabel()
    
    private var rate: Double = Double.random(in: 1...1000)

    private var timer: Timer?
    private var secondsLeft: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addSubviews()
        makeConstraints()
        bind()
        
        collectionView.reloadData()
        updateTopUI()
        startTimer()
    }
}

private extension TradeViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        collectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.identifier)
        
        collectionView.dataSource = currencyService
        collectionView.delegate = currencyService
        
        firstCurrencyButton.setTitle("USD", for: .normal)
        secondCurrencyButton.setTitle("BTC", for: .normal)
        
        amountTextField.placeholder = "Введите сумму"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        resultLabel.textAlignment = .center
        resultLabel.font = .systemFont(ofSize: 16, weight: .medium)

        timerLabel.textAlignment = .center
        timerLabel.textColor = .secondaryLabel
        
        firstCurrencyButton.setTitleColor(.systemMint, for: .normal)
        secondCurrencyButton.setTitleColor(.systemMint, for: .normal)
        
        rateLabel.textAlignment = .center
        
        firstCurrencyButton.addTarget(self, action: #selector(selectFirst), for: .touchUpInside)
        secondCurrencyButton.addTarget(self, action: #selector(selectSecond), for: .touchUpInside)
        
        filterControl.selectedSegmentIndex = 0
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }
    
    func addSubviews() {
        view.addSubview(firstCurrencyButton)
        view.addSubview(amountTextField)
        view.addSubview(resultLabel)
        view.addSubview(timerLabel)
        view.addSubview(secondCurrencyButton)
        view.addSubview(rateLabel)
        view.addSubview(filterControl)
        view.addSubview(collectionView)
    }
    
    func makeConstraints() {
        firstCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        secondCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        filterControl.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstCurrencyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            firstCurrencyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            secondCurrencyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            secondCurrencyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            rateLabel.topAnchor.constraint(equalTo: firstCurrencyButton.bottomAnchor, constant: 12),
            rateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filterControl.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 12),
            filterControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            amountTextField.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 12),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            resultLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 8),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timerLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 4),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
            collectionView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 16),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func bind() {
        currencyService.onUpdate = { [weak self] in
            self?.updateTopUI()
        }
    }
}

// MARK: - Actions
private extension TradeViewController {
    @objc func selectFirst() {
        currencyService.isSelectingFirst = true
        collectionView.reloadData()
    }
    
    @objc func selectSecond() {
        currencyService.isSelectingFirst = false
        collectionView.reloadData()
    }
    
    @objc func filterChanged() {
        switch filterControl.selectedSegmentIndex {
        case 1:
            currencyService.currentFilter = .fiat
        case 2:
            currencyService.currentFilter = .crypto
        default:
            currencyService.currentFilter = nil
        }
        
        currencyService.applyFilter()
        collectionView.reloadData()
    }
    
    @objc func textChanged() {
        calculate()
    }
}

// MARK: - UI Update
private extension TradeViewController {
    func updateTopUI() {
        firstCurrencyButton.setTitle(currencyService.selectedFirst?.name ?? "USD", for: .normal)
        secondCurrencyButton.setTitle(currencyService.selectedSecond?.name ?? "BTC", for: .normal)
        
        rateLabel.text = "Курс: \(String(format: "%.4f", rate))"
        
        calculate()
    }
    
    func updateRate() {
        rate = Double.random(in: 0.0001...1000)
        
        rateLabel.text = "Курс: \(String(format: "%.4f", rate))"
        
        calculate()
    }
    
    func calculate() {
        guard
            let text = amountTextField.text,
            let amount = Double(text),
            let second = currencyService.selectedSecond
        else {
            resultLabel.text = "-"
            return
        }
        
        let result = amount / rate
        
        resultLabel.text = "\(String(format: "%.4f", result)) \(second.name)"
    }
    
    func tick() {
        secondsLeft -= 1
        
        timerLabel.text = "Обновление через: \(secondsLeft)с"
        
        if secondsLeft == 0 {
            updateRate()
            secondsLeft = 5
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        secondsLeft = 5
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
}
