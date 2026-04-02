//
//  ControlsView.swift
//  Market
//
//  Created by Дмитриев Антон on 02.04.2026.
//

import Foundation
import UIKit

final class ControlsView: UIView {
    // MARK: - UI elements
    let verticalStackView = UIStackView()
    let horisontalStackView = UIStackView()
    let titleLabel = UILabel()
    var balanceLabel = UILabel()
    var currencyLabel = UILabel()
    var incomeLabel = UILabel()
    let button = UIButton()
    
    let tableView: UITableView = UITableView()
    let emptyDataLabel = UILabel()
    
    // MARK: - Actions
    var onRunTapped: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Setup
private extension ControlsView {
    func setupUI() {
        backgroundColor = .systemBackground
        
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 4
        
        horisontalStackView.axis = .horizontal
        horisontalStackView.spacing = 4
        
        titleLabel.text = "Брокерский счёт"
        
        balanceLabel.setContentHuggingPriority(.required, for: .horizontal)
        balanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        currencyLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        currencyLabel.textAlignment = .left
        
        incomeLabel.textColor = .systemGreen
        
        emptyDataLabel.text = "Нет данных"
        emptyDataLabel.textAlignment = .center
        emptyDataLabel.textColor = .secondaryLabel
        emptyDataLabel.font = UIFont.systemFont(ofSize: 16)
        emptyDataLabel.backgroundColor = .secondarySystemBackground
        
        let height: CGFloat = 50
        button.backgroundColor = .systemMint
        button.setTitle("Run", for: .normal)
        button.layer.cornerRadius = height / 2
        button.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
    }
    
    func addSubviews() {
        addSubview(verticalStackView)
        addSubview(emptyDataLabel)
        addSubview(tableView)
        addSubview(button)
        
        verticalStackView.addArrangedSubview(titleLabel)
        horisontalStackView.addArrangedSubview(balanceLabel)
        horisontalStackView.addArrangedSubview(currencyLabel)
        verticalStackView.addArrangedSubview(horisontalStackView)
        verticalStackView.addArrangedSubview(incomeLabel)
    }
    
    func makeConstraints() {
        makeStackViewConstraints()
        makeEmptyDataLabelConstraints()
        makeTableViewConstraints()
        makeButtonConstraints()
    }
}

// MARK: - Constraints
private extension ControlsView {
    func makeStackViewConstraints() {
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            verticalStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }
    
    func makeEmptyDataLabelConstraints() {
        emptyDataLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyDataLabel.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 16),
            emptyDataLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyDataLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            emptyDataLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16)
        ])
    }
    
    func makeTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16)
        ])
    }
    
    func makeButtonConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Actions
private extension ControlsView {
    @objc func handleButtonTapped() {
        onRunTapped?()
    }
}

// MARK: - Public methods
extension ControlsView {
    func configure(balance: String, currency: String, income: String) {
        balanceLabel.text = balance
        currencyLabel.text = currency
        incomeLabel.text = income
    }
    
    func showEmptyState() {
        emptyDataLabel.isHidden = false
        tableView.isHidden = true
    }
    
    func showData() {
        emptyDataLabel.isHidden = true
        tableView.isHidden = false
    }
}
