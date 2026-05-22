//
//  ShortCurrencyPairViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 10.04.2026.
//

import UIKit

final class ShortCurrencyPairViewController: UIViewController {
    private let currencyService: CurrencyService
    private var observerId: UUID?

    private let firstCurrencyButton = UIButton(type: .system)
    private let secondCurrencyButton = UIButton(type: .system)
    private let allButton = UIButton(type: .system)

    private let collectionView: UICollectionView

    init(currencyService: CurrencyService) {
        self.currencyService = currencyService

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        layoutUI()
        bind()

        title = "Избранные валюты"
        applyFavoritesOnly()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyFavoritesOnly()
    }

    deinit {
        if let id = observerId {
            currencyService.removeObserver(id: id)
        }
    }
}

private extension ShortCurrencyPairViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground

        firstCurrencyButton.setTitleColor(.systemMint, for: .normal)
        secondCurrencyButton.setTitleColor(.systemMint, for: .normal)

        allButton.setTitle("Все", for: .normal)
        allButton.setTitleColor(.systemBlue, for: .normal)
        allButton.addTarget(self, action: #selector(openFullList), for: .touchUpInside)

        firstCurrencyButton.addTarget(self, action: #selector(selectFirst), for: .touchUpInside)
        secondCurrencyButton.addTarget(self, action: #selector(selectSecond), for: .touchUpInside)

        collectionView.backgroundColor = .clear
        collectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.identifier)

        collectionView.dataSource = currencyService
        collectionView.delegate = currencyService
    }

    func layoutUI() {
        view.addSubview(firstCurrencyButton)
        view.addSubview(secondCurrencyButton)
        view.addSubview(allButton)
        view.addSubview(collectionView)

        firstCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        secondCurrencyButton.translatesAutoresizingMaskIntoConstraints = false
        allButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            firstCurrencyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            firstCurrencyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            secondCurrencyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            secondCurrencyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            allButton.topAnchor.constraint(equalTo: firstCurrencyButton.bottomAnchor, constant: 12),
            allButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: allButton.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func bind() {
        observerId = currencyService.addObserver { [weak self] in
            self?.updateUI()
            self?.collectionView.reloadData()
        }
    }
}

private extension ShortCurrencyPairViewController {
    func applyFavoritesOnly() {
        currencyService.applyFilter(type: currencyService.currentFilter, favoritesOnly: true)
    }

    func updateUI() {
        firstCurrencyButton.setTitle(currencyService.selectedFirst?.name ?? "1 валюта", for: .normal)
        secondCurrencyButton.setTitle(currencyService.selectedSecond?.name ?? "2 валюта", for: .normal)
    }

    @objc func selectFirst() {
        currencyService.isSelectingFirst = true
        collectionView.reloadData()
    }

    @objc func selectSecond() {
        currencyService.isSelectingFirst = false
        collectionView.reloadData()
    }

    @objc func openFullList() {
        let fullVC = CurrencyPairViewController(
            currencyService: currencyService,
            isSelectingFirst: currencyService.isSelectingFirst
        )

        fullVC.title = "Все валюты"

        navigationController?.pushViewController(fullVC, animated: true)
    }
}
