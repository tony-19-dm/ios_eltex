//
//  FeedbackViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 27.05.2026.
//

import Foundation
import UIKit

final class FeedbackViewController: UIViewController {
    private let viewModel = FeedbackViewModel()

    private let topicsView = SupportTopicView()
    
    private let nameField = UITextField()
    private let textView = UITextView()

    private let checkboxButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)

    private let agreementLabel = UILabel()

    private let overlayView = UIView()
    private let agreementTextView = UITextView()

    private var isChecked = false {
        didSet {
            updateCheckbox()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        makeConstraints()
    }
}

private extension FeedbackViewController {
    func setupUI() {
        title = "Обратная связь"

        view.backgroundColor = .systemBackground

        nameField.placeholder = "Ваше имя"
        nameField.borderStyle = .roundedRect

        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.cornerRadius = 12

        topicsView.delegate = self
        
        checkboxButton.addTarget(
            self,
            action: #selector(toggleCheckbox),
            for: .touchUpInside
        )

        sendButton.setTitle("Отправить", for: .normal)
        sendButton.isEnabled = false

        updateCheckbox()

        setupAgreementText()
        setupOverlay()
    }

    func makeConstraints() {
        let stack = UIStackView(arrangedSubviews: [
            nameField,
            textView,
            topicsView,
            checkboxButton,
            agreementLabel,
            sendButton
        ])

        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)
        view.addSubview(overlayView)

        stack.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        topicsView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            textView.heightAnchor.constraint(equalToConstant: 160),

            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            topicsView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    func setupAgreementText() {
        let text = "Я согласен на обработку данных"

        let attributed = NSMutableAttributedString(string: text)

        let range = (text as NSString).range(of: "обработку данных")

        attributed.addAttribute(
            .foregroundColor,
            value: UIColor.systemMint,
            range: range
        )

        agreementLabel.attributedText = attributed
        agreementLabel.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(openAgreement)
        )

        agreementLabel.addGestureRecognizer(tap)
    }

    func setupOverlay() {
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        overlayView.isHidden = true

        let container = UIView()

        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16

        agreementTextView.isEditable = false

        agreementTextView.text =
        """
        Соглашение об обработке персональных данных

        Тут должен быть ну оооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооочень длинный текст...
        """

        let closeButton = UIButton(type: .system)

        closeButton.setTitle("Закрыть", for: .normal)

        closeButton.addTarget(
            self,
            action: #selector(closeAgreement),
            for: .touchUpInside
        )

        container.addSubview(agreementTextView)
        container.addSubview(closeButton)

        overlayView.addSubview(container)

        container.translatesAutoresizingMaskIntoConstraints = false
        agreementTextView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -20),
            container.heightAnchor.constraint(equalToConstant: 400),
            
            agreementTextView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            agreementTextView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            agreementTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            agreementTextView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -16),

            closeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            closeButton.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
    }

    func updateCheckbox() {
        let image = isChecked ? "checkmark.square.fill" : "square"

        checkboxButton.setImage(UIImage(systemName: image), for: .normal)

        sendButton.isEnabled = isChecked
    }

    @objc func toggleCheckbox() {
        isChecked.toggle()
    }

    @objc func openAgreement() {
        overlayView.isHidden = false
    }

    @objc func closeAgreement() {
        overlayView.isHidden = true
    }
}

extension FeedbackViewController: SupportTopicViewDelegate {
    func supportTopicView(
        _ view: SupportTopicView,
        didUpdateSelectedTopics topics: [String]
    ) {
        viewModel.selectedTopics = topics

        print("Выбрано:", topics)
    }
}
