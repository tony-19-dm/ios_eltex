//
//  WalletViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 25.04.2026.
//

import Foundation
import UIKit

final class WalletViewController: UIViewController {
    private let wallet: Wallet
    
    private let textView = UITextView()
    
    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        loadBalances()
    }
    
    private func setupUI() {
        view.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 18)
        textView.isEditable = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadBalances() {
        let balances = wallet.getAllBalances()
        
        textView.text = balances.map {
            "\($0.name): \(($0.value).formatToString()) (credit: \($0.credit))"
        }.joined(separator: "\n")
    }
}
