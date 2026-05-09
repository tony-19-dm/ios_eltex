//
//  SellerInfoViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 09.05.2026.
//

import Foundation
import UIKit

final class SellerInfoViewController: UIViewController {
    private let stackView = UIStackView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    private let rateLabel = UILabel()
    private let reserveLabel = UILabel()
    private let ratingLabel = UILabel()
    private let tradesLabel = UILabel()
    private let memberLabel = UILabel()

    private let viewModel: SellerInfoViewModel

    init(viewModel: SellerInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Продавец"
        view.backgroundColor = .systemBackground
        setupUI()
        populate()
    }

    private func setupUI() {
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemMint
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        [nameLabel, idLabel, rateLabel, reserveLabel,
         ratingLabel, tradesLabel, memberLabel].forEach {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            stackView.addArrangedSubview($0)
        }

        nameLabel.font = .boldSystemFont(ofSize: 22)
        idLabel.font = .systemFont(ofSize: 13)
        idLabel.textColor = .secondaryLabel

        view.addSubview(avatarImageView)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),

            stackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func populate() {
        nameLabel.text = viewModel.sellerName
        idLabel.text = "ID: \(viewModel.sellerId)"
        rateLabel.text = "Курс: \(viewModel.rate)"
        reserveLabel.text = "Резерв: \(viewModel.reserve)"
        ratingLabel.text = "Рейтинг: \(viewModel.rating)"
        tradesLabel.text = "Сделок завершено: \(viewModel.completedTrades)"
        memberLabel.text = "На платформе с: \(viewModel.memberSince)"
    }
}
