//
//  SupportTopicView.swift
//  Market
//
//  Created by Дмитриев Антон on 04.06.2026.
//

import Foundation
import UIKit

protocol SupportTopicViewDelegate: AnyObject {
    func supportTopicView(
        _ view: SupportTopicView,
        didUpdateSelectedTopics topics: [String]
    )
}

final class SupportTopicView: UIView {
    weak var delegate: SupportTopicViewDelegate?

    private let topics = [
        "Проблема с выводом",
        "Проблема с ботом",
        "P2P продавец не отвечает",
        "Проблема с пополнением",
        "Другое"
    ]

    private var selectedTopics = Set<String>()

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension SupportTopicView {
    func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 8
        
        stackView.alignment = .fill
        stackView.distribution = .fill

        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        topics.forEach { topic in
            let button = UIButton(type: .system)

            button.setTitle("☐ \(topic)", for: .normal)

            button.contentHorizontalAlignment = .leading
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true

            button.addAction(
                UIAction { [weak self] _ in
                    self?.toggle(topic: topic, button: button)
                },
                for: .touchUpInside
            )

            stackView.addArrangedSubview(button)
        }
    }

    func toggle(topic: String, button: UIButton) {
        if selectedTopics.contains(topic) {
            selectedTopics.remove(topic)
            button.setTitle("☐ \(topic)", for: .normal)
        } else {
            selectedTopics.insert(topic)
            button.setTitle("☑︎ \(topic)", for: .normal)
        }

        delegate?.supportTopicView(
            self,
            didUpdateSelectedTopics: Array(selectedTopics)
        )
    }
}
