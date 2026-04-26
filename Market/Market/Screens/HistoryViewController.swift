//
//  ViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

final class HistoryViewController: UIViewController {
    private let controlsView = ControlsView()
    
    let wallet = Wallet()
    
    lazy var bots = [
        GCDBot(name: "BotBtcMaster", first: "BTC", second: "USD", wallet: wallet),
        GCDBot(name: "BotSuperBitcoin", first: "BTC", second: "USD", wallet: wallet),
        GCDBot(name: "BotBTCUSD", first: "BTC", second: "USD", wallet: wallet),
        GCDBot(name: "BotCryptoGenius", first: "BTC", second: "USD", wallet: wallet),
        GCDBot(name: "BotBtcMaestro", first: "BTC", second: "USD", wallet: wallet),
        GCDBot(name: "BotRUBETH", first: "RUB", second: "ETH", wallet: wallet),
        GCDBot(name: "BotFiatToEth", first: "RUB", second: "ETH", wallet: wallet),
        GCDBot(name: "BotEthMaster", first: "RUB", second: "ETH", wallet: wallet)
    ]
    
    private var startBalanse: Double = .zero
    private var totalBalance: Double = .zero
    
    private var observerId: UUID?
    
    deinit {
        if let id = observerId {
            currencyService.removeObserver(id: id)
        }
    }
    
    private var botResults: [TradeResult] = [] {
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
    func run() {
        botResults = generateBotsHistory()
        
        controlsView.showData()
    }
    
    func generateBotsHistory() -> [TradeResult] {
        var results: [TradeResult] = []
        
        let group = DispatchGroup()
        let lock = NSLock()
        
        for day in 1...AppConfig.days {
            for bot in bots {
                group.enter()
                
                DispatchQueue.global().sync {
                    
                    let result = bot.start(day: day)
                    
                    lock.lock()
                    results.append(result)
                    lock.unlock()
                    
                    group.leave()
                }
            }
        }
        
        group.wait()
        return results
    }
    
    func updateCurrencyUI() {
        controlsView.firstCurrencyLabel.text = currencyService.selectedFirst?.name ?? "BTC"
        controlsView.secondCurrencyLabel.text = currencyService.selectedSecond?.name ?? "USD"
    }
}

// MARK: - TableView
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        botResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let item = botResults[indexPath.row]
        
        let sign = item.income >= 0 ? "+" : ""
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(item.botName) (\(item.pair)), day = \(item.day), income = \(sign)\(Int(item.income))$"
        
        return cell
    }
}

// MARK: - Actions
private extension HistoryViewController {
    @objc func resetTapped() {
        currencyService.resetSelection()
        controlsView.showEmptyState()
    }
    
    @objc func randomTapped() {
        currencyService.randomPair()
        controlsView.showEmptyState()
    }
    
    @objc private func openWallet() {
        let vc = WalletViewController(wallet: wallet)
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
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
        
        let walletButton = UIBarButtonItem(
            image: UIImage(systemName: "wallet.bifold"),
            style: .plain,
            target: self,
            action: #selector(openWallet)
        )
            
        navigationItem.rightBarButtonItem = walletButton
        navigationItem.leftBarButtonItem = resetButton
    }
}

private extension HistoryViewController {
    func openCurrencySelector(selectingFirst: Bool) {
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
