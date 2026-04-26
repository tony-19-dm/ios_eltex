//
//  ExchangeViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 26.04.2026.
//

import Foundation
import UIKit

final class ExchangeViewController: UIViewController {
    private let networkService = NetworkService()
    private let offerGenerator = OfferGenerator()
    private let wallet: Wallet

    private var rates: [CurrencyRate] = []
    private var offers: [ExchangeOffer] = []

    private var fromCurrency: String = "USD"
    private var toCurrency: String = "EUR"

    private let tableView = UITableView()
    private let headerView = UIView()

    private let pairLabel = UILabel()
    private let walletLabel = UILabel()

    private let swapButton = UIButton(type: .system)

    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        makeConstraints()
        setupTable()

        loadRates()
    }
}

private extension ExchangeViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Обмен"

        pairLabel.font = .boldSystemFont(ofSize: 18)
        pairLabel.textAlignment = .center

        walletLabel.font = .systemFont(ofSize: 14)
        walletLabel.textAlignment = .center
        walletLabel.numberOfLines = 2

        swapButton.setTitle("Сменить пару", for: .normal)
        swapButton.addTarget(self, action: #selector(changePair), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "wallet.bifold"),
            style: .plain,
            target: self,
            action: #selector(openWallet)
        )

        view.addSubview(headerView)
        headerView.addSubview(pairLabel)
        headerView.addSubview(walletLabel)
        headerView.addSubview(swapButton)
        view.addSubview(tableView)
    }
}

private extension ExchangeViewController {
    func makeConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        pairLabel.translatesAutoresizingMaskIntoConstraints = false
        walletLabel.translatesAutoresizingMaskIntoConstraints = false
        swapButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            pairLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            pairLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            pairLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            walletLabel.topAnchor.constraint(equalTo: pairLabel.bottomAnchor, constant: 6),
            walletLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            walletLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            swapButton.topAnchor.constraint(equalTo: walletLabel.bottomAnchor, constant: 10),
            swapButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            swapButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10),

            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

private extension ExchangeViewController {
    func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

private extension ExchangeViewController {
    func loadRates() {
        networkService.loadRates { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let rates):
                    self.rates = rates
                    self.generateOffers()

                case .failure(let error):
                    self.showError(error)
                }
            }
        }
    }

    func generateOffers() {
        offers = offerGenerator.makeOffers(
            from: fromCurrency,
            to: toCurrency,
            rates: rates
        )

        updateUI()
    }
}

private extension ExchangeViewController {
    func updateUI() {
        pairLabel.text = "\(fromCurrency) → \(toCurrency)"

        let balances = wallet.getAllBalances()
        let text = balances
            .map { "\($0.name): \($0.value.formatToString())" }
            .joined(separator: " | ")

        walletLabel.text = text

        tableView.reloadData()
    }
}

extension ExchangeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        offers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        )

        let offer = offers[indexPath.row]

        cell.textLabel?.text = "\(offer.sellerName) | rate: \(offer.rate.formatToString()) | reserve: \(Int(offer.reserve))"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer = offers[indexPath.row]
        showExchangeAlert(offer: offer)
    }
}

private extension ExchangeViewController {
    func showExchangeAlert(offer: ExchangeOffer) {
        let alert = UIAlertController(
            title: "Обмен",
            message: "Введите сумму",
            preferredStyle: .alert
        )

        alert.addTextField()

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        alert.addAction(UIAlertAction(title: "Выполнить", style: .default) { _ in

            let amount = Double(alert.textFields?.first?.text ?? "") ?? 0

            self.networkService.makeExchange(amount: amount) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.wallet.updateBalance(
                            from: self.fromCurrency,
                            to: self.toCurrency,
                            amount: amount,
                            rate: offer.rate
                        )

                        self.updateUI()

                    case .failure(let error):
                        self.showError(error)
                    }
                }
            }
        })

        present(alert, animated: true)
    }
}

private extension ExchangeViewController {
    func showError(_ error: NetworkError) {
        let message: String

        switch error {
        case .noInternet:
            message = "Нет подключения к интернету"

        case .parsing:
            message = "Что-то пошло не так, попробуйте позже"

        case .forbidden:
            message = "У вас нет прав на просмотр данного раздела"

        case .unknown:
            message = "Ошибка операции"
        }

        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }
}

private extension ExchangeViewController {
    @objc func changePair() {
        swap(&fromCurrency, &toCurrency)
        loadRates()
    }
    @objc func openWallet() {
        let vc = WalletViewController(wallet: wallet)
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
}
