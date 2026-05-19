//
//  CurrencyCell.swift
//  Market
//
//  Created by Дмитриев Антон on 02.04.2026.
//

import Foundation
import UIKit

protocol CurrencyCellDelegate: AnyObject {
    func didToggleFavorite(currency: TradeCurrency)
}

final class CurrencyCell: UICollectionViewCell {
    private let currencyNameLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    
    private var currency: TradeCurrency?
    weak var delegate: CurrencyCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ currency: TradeCurrency, isSelected: Bool, isDisabled: Bool, isFavorite: Bool) {
        self.currency = currency
        currencyNameLabel.text = currency.name
        
        let starImage = isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        favoriteButton.setImage(starImage, for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemYellow : .systemGray
        
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
    
    @objc private func toggleFavorite() {
        guard let currency = currency else { return }
        delegate?.didToggleFavorite(currency: currency)
    }
}

private extension CurrencyCell {
    func addSubviews() {
        contentView.addSubview(currencyNameLabel)
        contentView.addSubview(favoriteButton)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    }
    
    func makeConstraints() {
        currencyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currencyNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            currencyNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            currencyNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            currencyNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            favoriteButton.widthAnchor.constraint(equalToConstant: 16),
            favoriteButton.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func setupUI() {
        currencyNameLabel.textAlignment = .center
    }
}

extension CurrencyCell {
    static let identifier: String = "CurrencyCell"
}
