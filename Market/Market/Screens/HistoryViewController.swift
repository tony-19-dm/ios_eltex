//
//  ViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

final class HistoryViewController: UIViewController {
    private let controlsView = ControlsView()
    
    private var tradeBot = TradeBot()
    private var startBalanse: Double = .zero
    private var totalBalance: Double = .zero
    
    private var observerId: UUID?
    
    deinit {
        if let id = observerId {
            currencyService.removeObserver(id: id)
        }
    }
    
    private var history: [TradeOperatiion] = [] {
        didSet {
            controlsView.tableView.reloadData()
        }
    }
    
    private let currencyService = CurrencyService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observerId = currencyService.addObserver { [weak self] in
            self?.updateCurrencyUI()
        }
        
        setupUI()
        setupNavigationBar()
        addSubviews()
        makeConstraints()
        
        setupTableView()
        bindActions()
        
        initBot()
        controlsView.showEmptyState()
        
        setupSwipe()
    }
}

// MARK: - Setup
private extension HistoryViewController {
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
        
        controlsView.onFirstCurrencyTapped = { [weak self] in
            self?.openCurrencySelector(selectingFirst: true)
        }

        controlsView.onSecondCurrencyTapped = { [weak self] in
            self?.openCurrencySelector(selectingFirst: false)
        }
    }
}

// MARK: - Logic
private extension HistoryViewController {
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
    
    func updateCurrencyUI() {
        controlsView.firstCurrencyLabel.text = currencyService.selectedFirst?.name ?? "BTC"
        controlsView.secondCurrencyLabel.text = currencyService.selectedSecond?.name ?? "USD"
    }
}

// MARK: - TableView
extension HistoryViewController: UITableViewDataSource {
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

// MARK: - Actions
private extension HistoryViewController {
    @objc private func resetTapped() {
        currencyService.resetSelection()
            
        tradeBot.reset()
        
        history = []
        controlsView.showEmptyState()
        
        initBot()
    }
    
    @objc private func randomTapped() {
        currencyService.randomPair()
            
        tradeBot.reset()
        
        history = []
        controlsView.showEmptyState()
        
        initBot()
    }
}

// MARK: - NavigationBar
private extension HistoryViewController {
    func setupNavigationBar() {
        let resetButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(resetTapped)
        )
        
        let randomButton = UIBarButtonItem(
            image: UIImage(systemName: "shuffle"),
            style: .plain,
            target: self,
            action: #selector(randomTapped)
        )
        
        navigationItem.leftBarButtonItem = resetButton
        navigationItem.rightBarButtonItem = randomButton
    }
}

private extension HistoryViewController {
    private func openCurrencySelector(selectingFirst: Bool) {
        currencyService.isSelectingFirst = selectingFirst
        
        let vc = ShortCurrencyPairViewController(currencyService: currencyService)
        
        vc.modalPresentationStyle = .pageSheet
        
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

private extension HistoryViewController {
    func setupSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        swipe.direction = .up
        
        view.addGestureRecognizer(swipe)
    }
    
    @objc private func handleSwipeUp() {
        tabBarController?.selectedIndex = 2
    }
}
