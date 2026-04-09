//
//  ViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

final class TradeHistoryViewController: UIViewController {
    private let controlsView = ControlsView()
    
    private var tradeBot = TradeBot()
    private var startBalanse: Double = .zero
    private var totalBalance: Double = .zero
    
    private var history: [TradeOperatiion] = [] {
        didSet {
            controlsView.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addSubviews()
        makeConstraints()
        
        setupTableView()
        bindActions()
        
        initBot()
        controlsView.showEmptyState()
    }
}

// MARK: - Setup
private extension TradeHistoryViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func addSubviews() {
        view.addSubview(controlsView)
    }
    
    func makeConstraints() {
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlsView.topAnchor.constraint(equalTo: view.topAnchor),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupTableView() {
        controlsView.tableView.dataSource = self
    }
    
    func bindActions() {
        controlsView.onRunTapped = { [weak self] in
            self?.run()
        }
    }
}

// MARK: - Logic
private extension TradeHistoryViewController {
    func initBot() {
        startBalanse = tradeBot.balance
        totalBalance = tradeBot.balance
        
        let totalIncome = totalBalance - startBalanse
        let incomePersent = totalIncome / startBalanse * 100
        
        controlsView.configure(
            balance: tradeBot.returnStringBalance(),
            currency: tradeBot.getCurrency(),
            income: "+ \(totalIncome.formatToString()) (\(incomePersent.formatToString())%)"
        )
    }
    
    func run() {
        startBalanse = tradeBot.balance
        
        history = tradeBot.generateHistory()
        totalBalance = tradeBot.balance
        
        let totalIncome = totalBalance - startBalanse
        let incomePersent = totalIncome / startBalanse * 100
        
        controlsView.configure(
            balance: tradeBot.returnStringBalance(),
            currency: tradeBot.getCurrency(),
            income: "+ \(totalIncome.formatToString()) (\(incomePersent.formatToString())%)"
        )
        
        controlsView.showData()
    }
}

// MARK: - TableView
extension TradeHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier) as? HistoryCell {
            cell.currentOperatiion = history[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
}
