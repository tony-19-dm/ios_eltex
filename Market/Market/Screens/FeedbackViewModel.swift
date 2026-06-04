//
//  FeedbackViewModel.swift
//  Market
//
//  Created by Дмитриев Антон on 04.06.2026.
//

import Foundation
import Combine

final class FeedbackViewModel: ObservableObject {
    @Published var name = ""
    @Published var message = ""
    @Published var isAgreementAccepted = false

    @Published var selectedTopics: [String] = []

    @Published var nameError: String?
    @Published var messageError: String?

    var canSend: Bool {
        isAgreementAccepted &&
        nameError == nil &&
        messageError == nil &&
        !name.isEmpty &&
        !message.isEmpty
    }

    func validateName() {
        if name.isEmpty {
            nameError = "Имя не должно быть пустым"
            return
        }
        if name.count < 3 {
            nameError = "Имя должно содержать минимум 3 символа"
            return
        }
        if name.count > 30 {
            nameError = "Имя должно содержать не более 30 символов"
            return
        }

        nameError = nil
    }

    func validateMessage() {
        if message.isEmpty {
            messageError = "Текст обращения не должен быть пустым"
            return
        }
        if message.count < 3 {
            messageError = "Текст обращения должен содержать минимум 3 символа"
            return
        }
        if message.count > 150 {
            messageError = "Текст обращения должен содержать не более 150 символов"
            return
        }

        messageError = nil
    }

    func clearNameError() {
        nameError = nil
    }

    func clearMessageError() {
        messageError = nil
    }
}
