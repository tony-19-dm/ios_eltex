//
//  ViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

class ViewController: UIViewController {
    private let verticalStackView = UIStackView()
    private let horisontalStackView = UIStackView()
    private let label_1 = UILabel()
    private var label_2 = UILabel()
    private var label_3 = UILabel()
    private var label_4 = UILabel()
    private let button = UIButton()
    private let scrollViev = UIScrollView()
    private let textView = UITextView()
    
    private var tradeBot = TradeBot()
    private var startBalanse = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addStackView()
        addLabel()
        addScrollView()
        addTextView()
        addButton()
        run()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func run() {
        startBalanse = tradeBot.balance
        let history = tradeBot.start()
        let totalBalance = tradeBot.balance
        let totalIncome = totalBalance - startBalanse
        let incomePersent = totalIncome / startBalanse * 100
        textView.text = history
        label_2.text = tradeBot.returnStringBalance()
        label_3.text = tradeBot.getValute()
        label_4.text = "+ \(tradeBot.formatPrice(totalIncome)) (\(tradeBot.formatPrice(incomePersent))%)"
    }
}

private extension ViewController {
    func addStackView() {
        verticalStackView.frame = CGRect(x: 16, y: 80, width: view.bounds.width - 32, height: view.bounds.height - 80)
        verticalStackView.axis = .vertical
        verticalStackView.addArrangedSubview(label_1)
        verticalStackView.addArrangedSubview(horisontalStackView)
        verticalStackView.spacing = 4
        horisontalStackView.axis = .horizontal
        horisontalStackView.spacing = 4
        horisontalStackView.addArrangedSubview(label_2)
        horisontalStackView.addArrangedSubview(label_3)
        verticalStackView.addArrangedSubview(label_4)
        verticalStackView.addArrangedSubview(scrollViev)
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
    
    func addScrollView() {
        scrollViev.addSubview(textView)
    }
    
    func addTextView() {
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.frame = CGRect(x: 16, y: 0, width: verticalStackView.bounds.width - 32, height: verticalStackView.bounds.height / 2)
        textView.backgroundColor = .secondarySystemBackground
    }
    
    func addButton () {
        let viewBound = view.bounds
        let width: CGFloat = 100
        let height: CGFloat = 50
        let YPos: CGFloat = viewBound.height - height - 40
        let xPos: CGFloat = (viewBound.width - width) / 2
        button.frame = CGRect(x: xPos, y: YPos, width: width, height: height)
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
