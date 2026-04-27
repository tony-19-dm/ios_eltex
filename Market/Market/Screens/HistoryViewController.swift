//
//  ViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

final class HistoryViewController: UIViewController {
    private let controlsView = ControlsView()
    
    private let wallet: Wallet
    
    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
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
        
        for bot in bots {
            group.enter()
            
            DispatchQueue.global().async {
                let result = bot.start(day: AppConfig.days)
                
                lock.lock()
                results.append(result)
                lock.unlock()
                
                group.leave()
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier) as? HistoryCell {
            cell.result = botResults[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - Actions
private extension HistoryViewController {
    @objc func resetTapped() {
        currencyService.resetSelection()
        controlsView.showEmptyState()
        wallet.resetWallet()
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
    
    @objc private func openCurrencyPair() {
        let vc = TradeViewController(currencyService: currencyService)

        vc.title = "Выбор валют"

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet

        present(nav, animated: true)
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
        
        let randomButton = UIBarButtonItem(
            image: UIImage(systemName: "shuffle"),
            style: .plain,
            target: self,
            action: #selector(randomTapped)
        )
        
        let pairButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left.arrow.right.circle"),
            style: .plain,
            target: self,
            action: #selector(openCurrencyPair)
        )
            
        navigationItem.rightBarButtonItems = [pairButton, walletButton]
        navigationItem.leftBarButtonItems = [resetButton, randomButton]
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
        tabBarController?.selectedIndex = 1
    }
}
