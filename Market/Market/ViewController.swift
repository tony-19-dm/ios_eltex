//
//  ViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

// MARK: - Main class
class ViewController: UIViewController {
    private let verticalStackView = UIStackView()
    private let horisontalStackView = UIStackView()
    private let label_1 = UILabel()
    private var label_2 = UILabel()
    private var label_3 = UILabel()
    private var label_4 = UILabel()
    private let button = UIButton()
    
    private let tableView:UITableView = UITableView()
    
    private let emptyDataLabel = UILabel()
    
    private var tradeBot = TradeBot()
    private var startBalanse: Double = 0.0
    private var totalBalance: Double = 0.0
    
    private var history: [TradeOperatiion] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        initBot()
        
        addStackView()
        addLabel()
        addEmptyDataLabel()
        addTableView()
        addButton()
    
        makeStackViewConstraints()
        makeButtonConstraints()
        makeEmptyDataLabelConstraints()
        makeTableViewConstraints()
        
        showEmptyDataState()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        tableView.dataSource = self
    }
    
    // MARK: - Initialization trading bot
    func initBot() {
        startBalanse = tradeBot.balance
        totalBalance = tradeBot.balance
        let totalIncome = totalBalance - startBalanse
        let incomePersent = totalIncome / startBalanse * 100
        label_2.text = tradeBot.returnStringBalance()
        label_3.text = tradeBot.getCurrency()
        label_4.text = "+ \(totalIncome.formatToString()) (\(incomePersent.formatToString())%)"
    }
    
    // MARK: - Start trading
    func run() {
        startBalanse = tradeBot.balance
        history = tradeBot.generateHistory()
        totalBalance = tradeBot.balance
        let totalIncome = totalBalance - startBalanse
        let incomePersent = totalIncome / startBalanse * 100
        label_2.text = tradeBot.returnStringBalance()
        label_3.text = tradeBot.getCurrency()
        label_4.text = "+ \(totalIncome.formatToString()) (\(incomePersent.formatToString())%)"
        
        showData()
    }
    
    private func showEmptyDataState() {
        emptyDataLabel.isHidden = false
        tableView.isHidden = true
    }
    
    private func showData() {
        emptyDataLabel.isHidden = true
        tableView.isHidden = false
    }
}

// MARK: - TableView extension
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier),
           let historyCell = cell as? HistoryCell {
            let historyText = history[indexPath.row]
            historyCell.currentOperatiion = historyText
            return historyCell
        }
        return UITableViewCell()
    }
}

// MARK: - UI elements extension
private extension ViewController {
    func addStackView() {
        verticalStackView.axis = .vertical
        verticalStackView.addArrangedSubview(label_1)
        verticalStackView.addArrangedSubview(horisontalStackView)
        verticalStackView.spacing = 4
        horisontalStackView.axis = .horizontal
        horisontalStackView.spacing = 4
        horisontalStackView.addArrangedSubview(label_2)
        horisontalStackView.addArrangedSubview(label_3)
        verticalStackView.addArrangedSubview(label_4)
        view.addSubview(verticalStackView)
    }
    
    func addLabel() {
        label_1.text = "Брокерский счёт"
        label_2.setContentHuggingPriority(.required, for: .horizontal)
        label_2.setContentCompressionResistancePriority(.required, for: .horizontal)
        label_3.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label_3.textAlignment = .left
        label_4.textColor = .systemGreen
    }
    
    func addEmptyDataLabel() {
        emptyDataLabel.text = "Нет данных"
        emptyDataLabel.textAlignment = .center
        emptyDataLabel.textColor = .secondaryLabel
        emptyDataLabel.font = UIFont.systemFont(ofSize: 16)
        emptyDataLabel.backgroundColor = .secondarySystemBackground
        view.addSubview(emptyDataLabel)
    }
    
    func addTableView() {
        view.addSubview(tableView)
    }
    
    func addButton () {
        let height: CGFloat = 50
        button.backgroundColor = .systemMint
        button.setTitle("Run", for: .normal)
        button.layer.cornerRadius = height / 2
        button.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func handleButtonTapped() {
        run()
    }
}

// MARK: - Constraints extension
private extension ViewController {
    func makeStackViewConstraints() {
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: verticalStackView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: verticalStackView, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: verticalStackView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 16)
        ])
    }
    
    func makeEmptyDataLabelConstraints() {
        emptyDataLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: emptyDataLabel, attribute: .top, relatedBy: .equal, toItem: verticalStackView, attribute: .bottom, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: emptyDataLabel, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: emptyDataLabel, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: emptyDataLabel, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .top, multiplier: 1, constant: -16)
        ])
    }
    
    func makeTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16)
        ])
    }
    
    func makeButtonConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -16)
        ])
    }
}
