//
//  CurrencyCell.swift
//  Market
//
//  Created by Дмитриев Антон on 02.04.2026.
//

import Foundation
import UIKit

final class CurrencyCell: UICollectionViewCell {
    private let currencyNameLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        addSubviews()
        makeConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ currency: TradeCurrency, isSelected: Bool, isDisabled: Bool) {
        
        currencyNameLabel.text = currency.name
        
        layer.cornerRadius = 8
        layer.borderWidth = 2
        
        if isDisabled {
            backgroundColor = .systemGray
            layer.borderColor = UIColor.systemMint.cgColor
        } else {
            backgroundColor = isSelected ? .systemMint : .systemBackground
            layer.borderColor = isSelected ? UIColor.systemGray.cgColor : UIColor.systemMint.cgColor
        }
    }
}

private extension CurrencyCell{
    func addSubviews() {
        contentView.addSubview(currencyNameLabel)
    }
    
    func makeConstraints() {
        currencyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            currencyNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            currencyNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            currencyNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
    
    func setupUI() {
        currencyNameLabel.textAlignment = .center
    }
}

// MARK: - Identifier
extension CurrencyCell {
    static let identifier: String = "CurrencyCell"
}
