//
//  CurrencyPairViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 10.04.2026.
//

import Foundation
import UIKit

final class CurrencyPairViewController: UIViewController {
    
    private var observerId: UUID?
    
    private let currencyService: CurrencyService

    private let firstCurrencyButton = UIButton(type: .system)
    private let secondCurrencyButton = UIButton(type: .system)
    
    private let collectionView: UICollectionView
    
    init(currencyService: CurrencyService, isSelectingFirst: Bool) {
        self.currencyService = currencyService
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        
        self.currencyService.isSelectingFirst = isSelectingFirst
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addSubviews()
        makeConstraints()
        bind()
        
        updateButtons()
    }
    
    deinit {
        if let id = observerId {
            currencyService.removeObserver(id: id)
        }
    }
}

// MARK: - Setup UI
private extension CurrencyPairViewController {
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        firstCurrencyButton.setTitleColor(.systemMint, for: .normal)
        secondCurrencyButton.setTitleColor(.systemMint, for: .normal)
        
        firstCurrencyButton.addTarget(self, action: #selector(selectFirst), for: .touchUpInside)
        secondCurrencyButton.addTarget(self, action: #selector(selectSecond), for: .touchUpInside)
        
        collectionView.backgroundColor = .clear
        collectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.identifier)
        
        collectionView.dataSource = currencyService
        collectionView.delegate = currencyService
    }
    
    func addSubviews() {
        view.addSubview(firstCurrencyButton)
        view.addSubview(secondCurrencyButton)
        view.addSubview(collectionView)
    }
    
    func makeConstraints() {
        firstCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        secondCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstCurrencyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            firstCurrencyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            secondCurrencyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            secondCurrencyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: firstCurrencyButton.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func bind() {
        observerId = currencyService.addObserver { [weak self] in
            self?.updateButtons()
            self?.collectionView.reloadData()
        }
    }
}

// MARK: - Actions
private extension CurrencyPairViewController {
    
    @objc func selectFirst() {
        currencyService.isSelectingFirst = true
        collectionView.reloadData()
    }
    
    @objc func selectSecond() {
        currencyService.isSelectingFirst = false
        collectionView.reloadData()
    }
}

// MARK: - UI Update
private extension CurrencyPairViewController {
    
    func updateButtons() {
        firstCurrencyButton.setTitle(
            currencyService.selectedFirst?.name ?? "1 валюта",
            for: .normal
        )
        
        secondCurrencyButton.setTitle(
            currencyService.selectedSecond?.name ?? "2 валюта",
            for: .normal
        )
    }
}
