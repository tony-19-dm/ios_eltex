//
//  SettingsViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 02.05.2026.
//

import Foundation
import UIKit

final class SettingsViewController: UIViewController {

    var onLogout: (() -> Void)?
    var onAutoLoginChanged: ((Bool) -> Void)?

    private let defaults = Defaults.shared

    private let autoLoginLabel = UILabel()
    private let autoLoginSwitch = UISwitch()
    private let logoutButton = UIButton(type: .system)

    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        makeConstraints()
        loadState()
    }

    private func loadState() {
        autoLoginSwitch.isOn = defaults.isAutoLogin
    }
}

private extension SettingsViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Настройки"

        autoLoginLabel.text = "Автовход"
        autoLoginLabel.font = .systemFont(ofSize: 17)

        autoLoginSwitch.onTintColor = .systemMint

        logoutButton.setTitle("Выйти", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.layer.cornerRadius = 10
        logoutButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        stackView.axis = .vertical
        stackView.spacing = 24
        
        autoLoginSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
}

private extension SettingsViewController {
    func makeConstraints() {
        let switchRow = UIStackView(arrangedSubviews: [
            autoLoginLabel,
            UIView(),
            autoLoginSwitch
        ])

        switchRow.axis = .horizontal

        stackView.addArrangedSubview(switchRow)
        stackView.addArrangedSubview(logoutButton)

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}

// MARK: - Actions
private extension SettingsViewController {
    @objc func switchChanged() {
        let value = autoLoginSwitch.isOn
        defaults.isAutoLogin = value
        onAutoLoginChanged?(value)
    }

    @objc func logoutTapped() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Вы действительно хотите выйти?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            guard let self else { return }

            self.defaults.isAutoLogin = false
            self.onLogout?()
        })

        present(alert, animated: true)
    }
}
