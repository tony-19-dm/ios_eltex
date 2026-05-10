//
//  P2PViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 09.05.2026.
//

import Foundation
import UIKit

final class P2PViewController: UIViewController {
    private let tableView = UITableView()

    private let viewModel: P2PViewModel

    init(viewModel: P2PViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "P2P"

        setupTable()
        bindViewModel()

        viewModel.viewDidLoad()
    }

    private func setupTable() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func bindViewModel() {
        viewModel.onOffersUpdated = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }

        viewModel.onTradeSuccess = { [weak self] message in
            self?.showSuccess(message: message)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showSuccess(message: String) {
        let alert = UIAlertController(title: "Успех", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension P2PViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.offers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer = viewModel.offers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = """
        \(offer.seller.name)
        Курс: \(String(format: "%.4f", offer.rate))
        Резерв: \(offer.seller.reserve)
        """
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let offer = viewModel.offers[indexPath.row]

        showTradeAlert(for: offer)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let offer = viewModel.offers[indexPath.row]

        return UIContextMenuConfiguration(actionProvider: { _ in
            let infoAction = UIAction(
                title: "Информация о продавце",
                image: UIImage(systemName: "person.circle")
            ) { [weak self] _ in
                self?.viewModel.selectOffer(offer)
            }
            return UIMenu(children: [infoAction])
        })
    }

    private func showTradeAlert(for offer: P2POffer) {
        let alert = UIAlertController(title: "Обмен", message: "Введите сумму", preferredStyle: .alert)
        alert.addTextField { tf in tf.keyboardType = .decimalPad }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выполнить", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  let amount = Double(text) else { return }
            self?.viewModel.performTrade(offer: offer, amount: amount)
        })
        present(alert, animated: true)
    }
}
