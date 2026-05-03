//
//  AuthViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 02.05.2026.
//

import Foundation
import UIKit
import Combine

final class AuthViewController: UIViewController {
    var onSuccessLogin: (() -> Void)?

    private let defaults = Defaults.shared
    
    private let icon = UIImageView(image: UIImage(named: "trade"))
    private let stackView = UIStackView()
    private let loginField = UITextField()
    private let passwordField = UITextField()
    private let actionButton = UIButton(type: .system)
    private let modeSwitch = UISegmentedControl(items: ["Вход", "Регистрация"])
    
    @Published var currentLogin: String = ""
    @Published var currentPassword: String = ""
    
    private var cancelabels = Set<AnyCancellable>()

    private var isRegisterMode: Bool {
        modeSwitch.selectedSegmentIndex == 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        makeConstraints()
        setupTap()
        setupBindings()
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
        actionButton.isEnabled = false

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
        if isRegisterMode {
            register(login: currentLogin, password: currentPassword)
        } else {
            loginUser(login: currentLogin, password: currentPassword)
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
            return false
        }

        if login.contains(" ") {
            return false
        }
        
        if password.contains(" ") {
            return false
        }

        if password.count < 6 {
            return false
        }

        return true
    }
}

private extension AuthViewController {
    func setupBindings() {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: loginField)
            .map({ ($0.object as? UITextField)?.text ?? "" })
            .sink { [weak self] text in
                self?.currentLogin = text
            }
            .store(in: &cancelabels)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordField)
            .map({ ($0.object as? UITextField)?.text ?? "" })
            .sink { [weak self] text in
                self?.currentPassword = text
            }
            .store(in: &cancelabels)
        
        Publishers.CombineLatest($currentLogin, $currentPassword)
            .map { [weak self] login, password in
                self?.validate(login: login, password: password) ?? false
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.actionButton.isEnabled = isValid
            }
            .store(in: &cancelabels)
    }
}
