//
//  CurrencyService.swift
//  Market
//
//  Created by Дмитриев Антон on 02.04.2026.
//

import Foundation
import UIKit

enum CurrencyType {
    case fiat
    case crypto
}

struct TradeCurrency {
    let name: String
    let type: CurrencyType
}

// MARK: - Generator
final class CurrencyGenerator {
    static func generate(count: Int) -> [TradeCurrency] {
        var result: [TradeCurrency] = []
        
        for _ in 0..<count {
            let name = randomName()
            let type: CurrencyType = Bool.random() ? .fiat : .crypto
            
            result.append(TradeCurrency(name: name, type: type))
        }
        
        return result
    }
    
    private static func randomName() -> String {
        let letters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var result: String = ""
        
        for _ in 0..<3 {
            guard let letter = letters.randomElement() else { continue }
            result.append(letter)
        }
        return String(result)
    }
}

final class CurrencyService: NSObject {
    var selectedFirst: TradeCurrency?
    var selectedSecond: TradeCurrency?
    
    var isSelectingFirst: Bool = true
    var onUpdate: (() -> Void)?
    
    var currencines: [TradeCurrency] = []
    var filteredCurrencies: [TradeCurrency] = []
    
    var currentFilter: CurrencyType? = nil
    
    override init() {
        currencines = CurrencyGenerator.generate(count: 102)
        filteredCurrencies = currencines
        super.init()
    }
    
    func applyFilter() {
        switch currentFilter {
        case .fiat:
            filteredCurrencies = currencines.filter { $0.type == .fiat }
        case .crypto:
            filteredCurrencies = currencines.filter { $0.type == .crypto }
        case nil:
            filteredCurrencies = currencines
        }
    }
}

extension CurrencyService: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCurrencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCell.identifier, for: indexPath) as? CurrencyCell else {
            return UICollectionViewCell()
        }
        
        let currency = filteredCurrencies[indexPath.row]
        
        let isSelected = currency.name == selectedFirst?.name || currency.name == selectedSecond?.name
        
        let isDisabled = (isSelectingFirst && currency.name == selectedSecond?.name) || (!isSelectingFirst && currency.name == selectedFirst?.name)
        
        cell.update(currency, isSelected: isSelected, isDisabled: isDisabled)
        
        return cell
    }
}

// MARK: - Actions
extension CurrencyService: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = filteredCurrencies[indexPath.row]
        
        // MARK: - Can not select equal
        if isSelectingFirst {
            if currency.name == selectedSecond?.name { return }
            selectedFirst = currency
        } else {
            if currency.name == selectedFirst?.name { return }
            selectedSecond = currency
        }
        
        collectionView.reloadData()
        onUpdate?()
    }
}
