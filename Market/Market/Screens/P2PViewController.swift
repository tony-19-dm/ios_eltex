//
//  P2PViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 27.04.2026.
//

import Foundation
import UIKit

final class P2PViewController: UIViewController {
    private let tableView = UITableView()
    private let service = P2PService()
    private let wallet: Wallet

    private var offers: [P2POffer] = []

    private let from: String
    private let to: String

    init(wallet: Wallet, from: String, to: String) {
        self.wallet = wallet
        self.from = from
        self.to = to
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupTable()
        load()
    }

    private func setupTable() {
        view.addSubview(tableView)

        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func load() {
        service.loadOffers(from: from, to: to) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let offers):
                    self?.offers = offers
                    self?.tableView.reloadData()

                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }

    private func showError(_ error: NetworkError) {
        let message: String

        switch error {
        case .noInternet:
            message = "Нет подключения к интернету"
        case .parsingError:
            message = "Что-то пошло не так, попробуйте позже"
        case .unauthorized:
            message = "Нет прав на просмотр данного раздела"
        default:
            message = "Ошибка"
        }

        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension P2PViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        offers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer = offers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text =
        """
        \(offer.seller.name)
        курс: \(String(format: "%.4f", offer.rate))
        резерв: \(offer.seller.reserve)
        """

        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer = offers[indexPath.row]

        let alert = UIAlertController(
            title: "Обмен",
            message: "Введите сумму",
            preferredStyle: .alert
        )

        alert.addTextField()

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        alert.addAction(UIAlertAction(title: "Выполнить", style: .default) { [weak self] _ in
            guard let amountText = alert.textFields?.first?.text,
                  let amount = Double(amountText),
                  let self = self else { return }

            self.performTrade(offer: offer, amount: amount)
        })

        present(alert, animated: true)
    }

    private func performTrade(offer: P2POffer, amount: Double) {
        let success = Bool.random()

        if success {
            wallet.ensureAccount(name: from)
            wallet.ensureAccount(name: to)
            
            wallet.updateBalance(
                from: from,
                to: to,
                amount: amount,
                rate: offer.rate
            )

            let alert = UIAlertController(title: "Успех", message: "Обмен выполнен", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)

        } else {
            let error = NetworkError.serverError(code: 500)
            showError(error)
        }
    }
}
