//
//  ViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

// MARK: - Main class
final class ViewController: UIViewController {
    private let verticalStackView = UIStackView()
    private let horisontalStackView = UIStackView()
    private let titleLabel = UILabel()
    private var balanceLabel = UILabel()
    private var currencyLabel = UILabel()
    private var incomeLabel = UILabel()
    private let button = UIButton()
    private let scrollView = UIScrollView()
    private let textView = UITextView()
    
    private let emptyDataLabel = UILabel()
    
    private var tradeBot = TradeBot()
    private var startBalanse: Double = .zero
    private var totalBalance: Double = .zero
    private var history: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        initBot()
        
        addStackView()
        addLabels()
        addEmptyDataLabel()
        addScrollView()
        addTextView()
        addButton()
    
        makeStackViewConstraints()
        makeButtonConstraints()
        makeEmptyDataLabelConstraints()
        makeScrollViewConstraints()
        makeTextViewConstraints()
        
        showEmptyDataState()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
}

private extension ViewController {
    // MARK: - Initialization trading bot
    func initBot() {
        startBalanse = tradeBot.balance
        totalBalance = tradeBot.balance
        let totalIncome = totalBalance - startBalanse
        let incomePersent = totalIncome / startBalanse * 100
        balanceLabel.text = tradeBot.returnStringBalance()
        currencyLabel.text = tradeBot.getCurrency()
        incomeLabel.text = "+ \(totalIncome.formatToString()) (\(incomePersent.formatToString())%)"
    }
    
    // MARK: - Start trading
    func run() {
        startBalanse = tradeBot.balance
        history = tradeBot.start()
        totalBalance = tradeBot.balance
        let totalIncome = totalBalance - startBalanse
        let incomePersent = totalIncome / startBalanse * 100
        balanceLabel.text = tradeBot.returnStringBalance()
        currencyLabel.text = tradeBot.getCurrency()
        incomeLabel.text = "+ \(totalIncome.formatToString()) (\(incomePersent.formatToString())%)"
        textView.text = history
        
        showData()
    }
    
    private func showEmptyDataState() {
        emptyDataLabel.isHidden = false
        scrollView.isHidden = true
    }
    
    private func showData() {
        emptyDataLabel.isHidden = true
        scrollView.isHidden = false
    }
}

// MARK: - UI elements extension
private extension ViewController {
    func addStackView() {
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 4
        horisontalStackView.axis = .horizontal
        horisontalStackView.spacing = 4
        view.addSubview(verticalStackView)
    }
    
    func addLabels() {
        titleLabel.text = "Брокерский счёт"
        balanceLabel.setContentHuggingPriority(.required, for: .horizontal)
        balanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        currencyLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        currencyLabel.textAlignment = .left
        incomeLabel.textColor = .systemGreen
        
        verticalStackView.addArrangedSubview(titleLabel)
        horisontalStackView.addArrangedSubview(balanceLabel)
        horisontalStackView.addArrangedSubview(currencyLabel)
        verticalStackView.addArrangedSubview(horisontalStackView)
        verticalStackView.addArrangedSubview(incomeLabel)
    }
    
    func addEmptyDataLabel() {
        emptyDataLabel.text = "Нет данных"
        emptyDataLabel.textAlignment = .center
        emptyDataLabel.textColor = .secondaryLabel
        emptyDataLabel.font = UIFont.systemFont(ofSize: 16)
        emptyDataLabel.backgroundColor = .secondarySystemBackground
        view.addSubview(emptyDataLabel)
    }
    
    func addScrollView() {
        view.addSubview(scrollView)
    }
    
    func addTextView() {
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        scrollView.addSubview(textView)
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
    
    func makeScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: verticalStackView, attribute: .bottom, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .top, multiplier: 1, constant: -16)
        ])
    }
    
    func makeTextViewConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0)
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
