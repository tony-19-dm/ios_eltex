//
//  BotCheckCommand.swift
//  Market
//
//  Created by Дмитриев Антон on 04.06.2026.
//

import Foundation
import SwiftUI

struct BotCheckCommand {
    let direction: SwipeDirection
    let label: String

    static let all: [BotCheckCommand] = [
        .init(direction: .down,  label: "↓  Сверху вниз"),
        .init(direction: .up,    label: "↑  Снизу вверх"),
        .init(direction: .right, label: "→  Слева направо"),
        .init(direction: .left,  label: "←  Справа налево"),
    ]

    static func randomSequence(count: Int = 3) -> [BotCheckCommand] {
        (0..<count).map { _ in all.randomElement()! }
    }
}
