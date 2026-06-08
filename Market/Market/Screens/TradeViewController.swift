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

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )

    private let topMenuStackView = UIStackView()
    private let currenciesStackView = UIStackView()

    private let leftSpacer = UIView()
    private let rightSpacer = UIView()

    private let firstCurrencyButton = UIButton(type: .system)
    private let secondCurrencyButton = UIButton(type: .system)

    private let firstBalanceLabel = UILabel()
    private let secondBalanceLabel = UILabel()

    private let rateLabel = UILabel()
    private let timerLabel = UILabel()
    private let resultLabel = UILabel()

    private let amountTextField = UITextField()
    private let favoritesFilterView = FavoritesFilterView()

    private let filterControl = UISegmentedControl(
        items: ["All", "Fiat", "Crypto", "API only"]
    )

    private let currencyService: CurrencyService
    private let wallet: Wallet

    private var observerId: UUID?
    private var rate: Double = 1
    private var timer: Timer?
    private var secondsLeft = 5

    init(currencyService: CurrencyService, wallet: Wallet) {
        self.currencyService = currencyService
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    deinit {
        timer?.invalidate()

        if let id = observerId {
            currencyService.removeObserver(id: id)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupNavigationBar()
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
        title = "Trade"

        topMenuStackView.axis = .vertical
        topMenuStackView.spacing = 12

        currenciesStackView.axis = .horizontal
        currenciesStackView.distribution = .equalSpacing

        collectionView.backgroundColor = .clear
        collectionView.register(
            CurrencyCell.self,
            forCellWithReuseIdentifier: CurrencyCell.identifier
        )

        collectionView.dataSource = currencyService
        collectionView.delegate = currencyService

        firstCurrencyButton.setTitle("1 валюта", for: .normal)
        secondCurrencyButton.setTitle("2 валюта", for: .normal)

        firstCurrencyButton.setTitleColor(.systemMint, for: .normal)
        secondCurrencyButton.setTitleColor(.systemMint, for: .normal)

        firstCurrencyButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        secondCurrencyButton.titleLabel?.font = .boldSystemFont(ofSize: 18)

        firstCurrencyButton.addTarget(self, action: #selector(selectFirst), for: .touchUpInside)
        secondCurrencyButton.addTarget(self, action: #selector(selectSecond), for: .touchUpInside)

        [firstBalanceLabel, secondBalanceLabel].forEach {
            $0.font = .systemFont(ofSize: 13)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
        }

        rateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        rateLabel.textAlignment = .center

        timerLabel.font = .systemFont(ofSize: 13)
        timerLabel.textAlignment = .center
        timerLabel.textColor = .secondaryLabel

        resultLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        resultLabel.textAlignment = .center

        amountTextField.placeholder = "Введите сумму"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        filterControl.selectedSegmentIndex = 0
        filterControl.selectedSegmentTintColor = .systemMint
        filterControl.backgroundColor = .secondarySystemBackground
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    func setupNavigationBar() {
        let p2pButton = UIBarButtonItem(
            title: "P2P",
            style: .plain,
            target: self,
            action: #selector(openP2P)
        )

        navigationItem.rightBarButtonItem = p2pButton
    }

    func addSubviews() {
        view.addSubview(topMenuStackView)
        view.addSubview(collectionView)

        topMenuStackView.addArrangedSubview(currenciesStackView)

        topMenuStackView.addArrangedSubview(firstBalanceLabel)
        topMenuStackView.addArrangedSubview(secondBalanceLabel)

        topMenuStackView.addArrangedSubview(rateLabel)
        topMenuStackView.addArrangedSubview(timerLabel)
        topMenuStackView.addArrangedSubview(amountTextField)
        topMenuStackView.addArrangedSubview(resultLabel)
        topMenuStackView.addArrangedSubview(favoritesFilterView)
        topMenuStackView.addArrangedSubview(filterControl)

        favoritesFilterView.delegate = self

        currenciesStackView.addArrangedSubview(leftSpacer)
        currenciesStackView.addArrangedSubview(firstCurrencyButton)
        currenciesStackView.addArrangedSubview(secondCurrencyButton)
        currenciesStackView.addArrangedSubview(rightSpacer)
    }

    func makeConstraints() {
        topMenuStackView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topMenuStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            topMenuStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topMenuStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: topMenuStackView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func bind() {
        observerId = currencyService.addObserver { [weak self] in
            DispatchQueue.main.async {
                self?.updateTopUI()
                self?.collectionView.reloadData()
            }
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

    @objc func textChanged() {
        calculate()
    }

    @objc func openP2P() {
        guard
            let from = currencyService.selectedFirst?.name,
            let to = currencyService.selectedSecond?.name
        else {
            showAlert("Выберите валютную пару")
            return
        }

        let vc = P2PViewController(
            wallet: wallet,
            from: from,
            to: to
        )

        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func filterChanged() {
        switch filterControl.selectedSegmentIndex {
        case 1:
            currencyService.apiOnlyMode = false
            currencyService.currentFilter = .fiat

        case 2:
            currencyService.apiOnlyMode = false
            currencyService.currentFilter = .crypto

        case 3:
            currencyService.apiOnlyMode = true
            currencyService.applyAPIOnlyMode()
            collectionView.reloadData()
            return

        default:
            currencyService.apiOnlyMode = false
            currencyService.currentFilter = nil
        }

        currencyService.applyFavoritesFilter(
            isActive: favoritesFilterView.toggle.isOn
        )

        collectionView.reloadData()
    }

    func showAlert(_ text: String) {
        let alert = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UI Update
private extension TradeViewController {
    func updateTopUI() {
        firstCurrencyButton.setTitle(currencyService.selectedFirst?.name ?? "1 валюта", for: .normal)
        secondCurrencyButton.setTitle(currencyService.selectedSecond?.name ?? "2 валюта", for: .normal)

        updateBalances()

        guard
            let first = currencyService.selectedFirst,
            let second = currencyService.selectedSecond
        else {
            rateLabel.text = "Выберите валюты"
            resultLabel.text = "-"
            return
        }

        let newRate = second.rate / first.rate
        rate = newRate

        rateLabel.text = "Курс: \(String(format: "%.4f", newRate))"
        calculate()
    }

    func updateBalances() {
        guard let first = currencyService.selectedFirst?.name,
              let second = currencyService.selectedSecond?.name else {
            return
        }

        let firstBalance = wallet.getBalance(name: first)
        let secondBalance = wallet.getBalance(name: second)

        firstBalanceLabel.text = "Баланс \(first): \(firstBalance)"
        secondBalanceLabel.text = "Баланс \(second): \(secondBalance)"
    }

    func calculate() {
        guard
            let text = amountTextField.text,
            let amount = Double(text)
        else {
            resultLabel.text = "-"
            return
        }

        let result = amount / rate
        resultLabel.text = "\(String(format: "%.4f", result))"
    }

    func startTimer() {
        timer?.invalidate()

        secondsLeft = 5
        timerLabel.text = "Обновление через: 5с"

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }

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
        if currencyService.apiOnlyMode {
            currencyService.applyAPIOnlyMode()
        } else {
            currencyService.applyFavoritesFilter(isActive: isActive)
        }

        collectionView.reloadData()
    }
}
