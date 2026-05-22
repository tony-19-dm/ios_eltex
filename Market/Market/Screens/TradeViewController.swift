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
    
    private let topMenuStackView = UIStackView()
    private let currenciesStackView = UIStackView()
    
    private let leftSpacer = UIView()
    private let rightSpacer = UIView()
    
    private let firstCurrencyButton = UIButton()
    private let secondCurrencyButton = UIButton()
    private let rateLabel = UILabel()
    
    private let currencyService = CurrencyService()
    
    private let favoritesFilterView = FavoritesFilterView()
    private let filterControl = UISegmentedControl(items: ["All", "Fiat", "Crypto"])
    
    private let amountTextField = UITextField()
    private let resultLabel = UILabel()
    private let timerLabel = UILabel()
    
    private var rate: Double = Double.random(in: 0.001...1000)
    private var timer: Timer?
    private var secondsLeft: Int = 5
    
    private var observerId: UUID?
    
    deinit {
        if let id = observerId {
            currencyService.removeObserver(id: id)
        }
    }
    
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

// MARK: - UI elements extension
private extension TradeViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        topMenuStackView.axis = .vertical
        topMenuStackView.spacing = 16
        
        currenciesStackView.axis = .horizontal
        currenciesStackView.distribution = .equalSpacing
        
        collectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.identifier)
        collectionView.dataSource = currencyService
        collectionView.delegate = currencyService
        
        firstCurrencyButton.setTitle("1 валюта", for: .normal)
        secondCurrencyButton.setTitle("2 валюта", for: .normal)
        
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
        view.addSubview(topMenuStackView)
        view.addSubview(collectionView)
        
        topMenuStackView.addArrangedSubview(currenciesStackView)
        topMenuStackView.addArrangedSubview(rateLabel)
        topMenuStackView.addArrangedSubview(timerLabel)
        topMenuStackView.addArrangedSubview(amountTextField)
        topMenuStackView.addArrangedSubview(resultLabel)

        topMenuStackView.addArrangedSubview(favoritesFilterView)
        favoritesFilterView.delegate = self
        
        topMenuStackView.addArrangedSubview(filterControl)
        
        currenciesStackView.addArrangedSubview(leftSpacer)
        currenciesStackView.addArrangedSubview(firstCurrencyButton)
        currenciesStackView.addArrangedSubview(secondCurrencyButton)
        currenciesStackView.addArrangedSubview(rightSpacer)
    }
    
    func makeConstraints() {
        topMenuStackView.translatesAutoresizingMaskIntoConstraints = false
        currenciesStackView.translatesAutoresizingMaskIntoConstraints = false
        firstCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        secondCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        filterControl.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topMenuStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            topMenuStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topMenuStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            currenciesStackView.topAnchor.constraint(equalTo: topMenuStackView.topAnchor),
            currenciesStackView.leadingAnchor.constraint(equalTo: topMenuStackView.leadingAnchor),
            currenciesStackView.trailingAnchor.constraint(equalTo: topMenuStackView.trailingAnchor),
            
            rateLabel.centerXAnchor.constraint(equalTo: topMenuStackView.centerXAnchor),
            filterControl.centerXAnchor.constraint(equalTo: topMenuStackView.centerXAnchor),
            
            amountTextField.leadingAnchor.constraint(equalTo: topMenuStackView.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: topMenuStackView.trailingAnchor, constant: -16),
            
            resultLabel.centerXAnchor.constraint(equalTo: topMenuStackView.centerXAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: topMenuStackView.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topMenuStackView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func bind() {
        observerId = currencyService.addObserver { [weak self] in
            self?.updateTopUI()
            self?.collectionView.reloadData()
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
        case 1: currencyService.currentFilter = .fiat
        case 2: currencyService.currentFilter = .crypto
        default: currencyService.currentFilter = nil
        }
        currencyService.applyFavoritesFilter(isActive: favoritesFilterView.toggle.isOn)
        collectionView.reloadData()
    }
    
    @objc func textChanged() {
        calculate()
    }
}

// MARK: - UI Update
private extension TradeViewController {
    func updateTopUI() {
        firstCurrencyButton.setTitle(currencyService.selectedFirst?.name ?? "1 валюта", for: .normal)
        secondCurrencyButton.setTitle(currencyService.selectedSecond?.name ?? "2 валюта", for: .normal)
        
        if let firstName = currencyService.selectedFirst?.name,
           let secondName = currencyService.selectedSecond?.name,
           let first = currencyService.currencies.first(where: { $0.name == firstName }),
           let second = currencyService.currencies.first(where: { $0.name == secondName }) {
            
            let rate = second.rate / first.rate
            rateLabel.text = "Курс: \(String(format: "%.4f", rate))"
            self.rate = rate
        }
        calculate()
    }
    
    func calculate() {
        guard let text = amountTextField.text,
              let amount = Double(text),
              let _ = currencyService.selectedSecond else {
            resultLabel.text = "-"
            return
        }
        let result = amount / rate
        resultLabel.text = "\(String(format: "%.4f", result)) \(currencyService.selectedSecond?.name ?? "")"
    }
    
    func startTimer() {
        timer?.invalidate()
        secondsLeft = 5
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.secondsLeft -= 1
            self.timerLabel.text = "Обновление через: \(self.secondsLeft)с"
            if self.secondsLeft == 0 {
                self.currencyService.updateRates()
                self.secondsLeft = 5
            }
        }
    }
}

// MARK: - Favorites Filter Delegate
extension TradeViewController: FavoritesFilterViewDelegate {
    func favoritesFilterChanged(isActive: Bool) {
        currencyService.applyFavoritesFilter(isActive: isActive)
        collectionView.reloadData()
        
        if currencyService.filteredCurrencies.isEmpty && isActive {
            let emptyLabel = UILabel()
            emptyLabel.text = "Нет избранных валют"
            emptyLabel.textAlignment = .center
            collectionView.backgroundView = emptyLabel
        } else {
            collectionView.backgroundView = nil
        }
    }
}
