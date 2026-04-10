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

struct TradeCurrency: Hashable {
    let name: String
    let type: CurrencyType
    var rate: Double
}

final class CurrencyGenerator {
    static func generate(count: Int) -> [TradeCurrency] {
        var result: [TradeCurrency] = []
        for _ in 0..<count {
            let name = randomName()
            let type: CurrencyType = Bool.random() ? .fiat : .crypto
            let rate: Double = Double.random(in: 0.001...1000)
            result.append(TradeCurrency(name: name, type: type, rate: rate))
        }
        return result
    }
    
    private static func randomName() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<3).compactMap { _ in letters.randomElement() })
    }
}

final class CurrencyService: NSObject {
    var selectedFirst: TradeCurrency?
    var selectedSecond: TradeCurrency?
    var isSelectingFirst: Bool = true
    
    var currencies: [TradeCurrency] = []
    var filteredCurrencies: [TradeCurrency] = []
    var favorites: Set<String> = []
    
    var currentFilter: CurrencyType? = nil
    private var observers: [UUID: () -> Void] = [:]
    
    override init() {
        super.init()
        currencies = CurrencyGenerator.generate(count: 102)
        filteredCurrencies = currencies
        
        randomFavorites()
    }
    
    func applyFilter(type: CurrencyType? = nil, favoritesOnly: Bool = false) {
        currentFilter = type
        
        var result = currencies
        
        if let type = type {
            result = result.filter { $0.type == type }
        }
        if favoritesOnly {
            result = result.filter { favorites.contains($0.name) }
        }
        
        filteredCurrencies = result
        notify()
    }
    
    func applyFavoritesFilter(isActive: Bool) {
        applyFilter(type: currentFilter, favoritesOnly: isActive)
    }
    
    func updateRates() {
        currencies = currencies.map { currency in
            var updated = currency
            updated.rate = Double.random(in: 0.001...1000)
            return updated
        }
        applyFavoritesFilter(isActive: false)
    }
    
    func toggleFavorite(currency: TradeCurrency) {
        if favorites.contains(currency.name) {
            favorites.remove(currency.name)
        } else {
            favorites.insert(currency.name)
        }
        applyFavoritesFilter(isActive: false)
    }
    
    func addObserver(_ observer: @escaping () -> Void) -> UUID {
        let id = UUID()
        observers[id] = observer
        return id
    }

    func removeObserver(id: UUID) {
        observers.removeValue(forKey: id)
    }

    private func notify() {
        observers.values.forEach { $0() }
    }
    
    func resetSelection() {
        selectedFirst = nil
        selectedSecond = nil
        isSelectingFirst = true
        notify()
    }
    
    func randomFavorites() {
        for _ in 0..<10 {
            guard let favorite = currencies.randomElement() else { return }
            favorites.insert(favorite.name)
        }
    }
    
    func randomPair() {
        let shuffled = currencies.shuffled()
        
        selectedFirst = shuffled.first
        selectedSecond = shuffled.dropFirst().first
        
        notify()
    }
}

// MARK: - UICollectionView DataSource
extension CurrencyService: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCurrencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CurrencyCell.identifier,
            for: indexPath
        ) as? CurrencyCell else { return UICollectionViewCell() }
        
        let currency = filteredCurrencies[indexPath.row]
        let isSelected = currency.name == selectedFirst?.name || currency.name == selectedSecond?.name
        let isDisabled = (isSelectingFirst && currency.name == selectedSecond?.name) ||
                         (!isSelectingFirst && currency.name == selectedFirst?.name)
        let isFavorite = favorites.contains(currency.name)
        
        cell.update(currency, isSelected: isSelected, isDisabled: isDisabled, isFavorite: isFavorite)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionView Delegate
extension CurrencyService: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = filteredCurrencies[indexPath.row]
        if isSelectingFirst {
            if currency.name == selectedSecond?.name { return }
            selectedFirst = currency
        } else {
            if currency.name == selectedFirst?.name { return }
            selectedSecond = currency
        }
        collectionView.reloadData()
        notify()
    }
}

// MARK: - CurrencyCell Delegate
extension CurrencyService: CurrencyCellDelegate {
    func didToggleFavorite(currency: TradeCurrency) {
        toggleFavorite(currency: currency)
    }
}
