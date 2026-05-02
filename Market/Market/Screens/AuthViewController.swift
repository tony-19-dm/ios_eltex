//
//  AuthViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 02.05.2026.
//

import Foundation
import UIKit

final class AuthViewController: UIViewController {
    var onSuccessLogin: (() -> Void)?

    private let defaults = Defaults.shared
    
    private let icon = UIImageView(image: UIImage(named: "trade"))
    private let stackView = UIStackView()
    private let loginField = UITextField()
    private let passwordField = UITextField()
    private let actionButton = UIButton(type: .system)
    private let modeSwitch = UISegmentedControl(items: ["Вход", "Регистрация"])

    private var isRegisterMode: Bool {
        modeSwitch.selectedSegmentIndex == 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        makeConstraints()
        setupTap()
    }
}

private extension AuthViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground

        loginField.placeholder = "Логин"
        loginField.borderStyle = .roundedRect
        loginField.autocapitalizationType = .none

        passwordField.placeholder = "Пароль"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true

        actionButton.setTitle("Вперед", for: .normal)
        actionButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)

        modeSwitch.selectedSegmentIndex = 0
        
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(loginField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(actionButton)
        stackView.addArrangedSubview(modeSwitch)
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        loginField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
    }
}

private extension AuthViewController {
    func makeConstraints () {
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 100),
            icon.widthAnchor.constraint(equalToConstant: 100),
            
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            loginField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            loginField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            passwordField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }
}

private extension AuthViewController {
    func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func handleAction() {
        guard
            let login = loginField.text?.trimmingCharacters(in: .whitespaces),
            let password = passwordField.text?.trimmingCharacters(in: .whitespaces),
            !login.isEmpty,
            !password.isEmpty
        else {
            return
        }

        guard validate(login: login, password: password) else { return }
        
        if isRegisterMode {
            register(login: login, password: password)
        } else {
            loginUser(login: login, password: password)
        }
    }

    func register(login: String, password: String) {
        defaults.login = login
        defaults.password = password
        defaults.isAutoLogin = true

        onSuccessLogin?()
    }

    func loginUser(login: String, password: String) {
        guard
            login == defaults.login,
            password == defaults.password
        else {
            return
        }

        onSuccessLogin?()
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func validate(login: String, password: String) -> Bool {
        if login.count < 3 {
            showError("Логин минимум 3 символа")
            return false
        }

        if login.contains(" ") {
            showError("Логин не должен содержать пробелы")
            return false
        }

        if password.count < 6 {
            showError("Пароль минимум 6 символов")
            return false
        }

        return true
    }
    
    func showError(_ text: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: text,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
