//
//  BotCheckViewModel.swift
//  Market
//
//  Created by Дмитриев Антон on 04.06.2026.
//

import Foundation
import SwiftUI
import Combine

enum BotCheckResult { case success, failure }

final class BotCheckViewModel: ObservableObject {
    private let commands: [BotCheckCommand]
    let totalSteps: Int

    @Published private(set) var currentStep: Int = 0
    @Published var highlightColor: Color = .blue

    @Published var showAlert = false
    @Published private(set) var alertTitle = ""
    @Published private(set) var alertMessage = ""

    @Published private(set) var result: BotCheckResult?

    var currentCommand: BotCheckCommand { commands[currentStep] }

    init() {
        let seq = BotCheckCommand.randomSequence(count: 3)
        self.commands = seq
        self.totalSteps = seq.count
    }

    func handleSwipe(_ direction: SwipeDirection) {
        let isCorrect = direction == currentCommand.direction

        if isCorrect {
            if currentStep + 1 < totalSteps {
                withAnimation { currentStep += 1 }
            } else {
                alertTitle   = "Готово"
                alertMessage = "Сообщение отправлено"
                showAlert    = true
            }
        } else {
            alertTitle   = "Проверка не пройдена"
            alertMessage = "Попробуйте ещё раз"
            showAlert    = true
        }
    }

    func handleAlertDismiss() {
        if alertTitle == "Готово" {
            result = .success
        } else {
            result = .failure
        }
    }
}
