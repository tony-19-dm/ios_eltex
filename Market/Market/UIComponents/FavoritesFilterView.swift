//
//  FavoritesFilterView.swift
//  Market
//
//  Created by Дмитриев Антон on 03.04.2026.
//

import Foundation
import UIKit

protocol FavoritesFilterViewDelegate: AnyObject {
    func favoritesFilterChanged(isActive: Bool)
}

final class FavoritesFilterView: UIView {
    weak var delegate: FavoritesFilterViewDelegate?
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Избранное"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        return toggle
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [label, toggle])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        toggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }
    
    @objc private func switchChanged() {
        delegate?.favoritesFilterChanged(isActive: toggle.isOn)
    }
}
