//
//  HistoryCell.swift
//  Market
//
//  Created by Дмитриев Антон on 27.03.2026.
//

import Foundation
import UIKit

struct TradeOperatiion {
    let id: UUID
    let text: String
    let operation: Decision
}

final class HistoryCell: UITableViewCell {
    private let historyLabel: UILabel = UILabel()
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    var result: TradeResult? {
        didSet {
            updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        makeConstraints()
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension HistoryCell {
    func updateUI() {
        guard let result else { return }
        let sign = result.income >= 0 ? "+" : ""
            historyLabel.text = "\(result.botName) (\(result.pair)), day = \(result.day), income = \(sign)\(Int(result.income))$"

            historyLabel.textColor = result.income >= 0 ? .systemGreen : .systemRed

            topConstraint?.isActive = false
            bottomConstraint?.isActive = false

            topConstraint = historyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
            bottomConstraint = historyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)

            topConstraint?.isActive = true
            bottomConstraint?.isActive = true
    }
    
    func addSubviews() {
        contentView.addSubview(historyLabel)
    }
    
    func makeConstraints() {
        historyLabel.translatesAutoresizingMaskIntoConstraints = false
        historyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        historyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
    
    func setUpUI() {
        historyLabel.font = .systemFont(ofSize: 14)
        historyLabel.numberOfLines = .zero
        contentView.backgroundColor = .secondarySystemBackground
    }
}

// MARK: - Identifier
extension HistoryCell {
    static let identifier: String = "TextHistoryCell"
}
