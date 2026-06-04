//
//  SwipeDirection.swift
//  Market
//
//  Created by Дмитриев Антон on 04.06.2026.
//

import Foundation
import CoreGraphics

enum SwipeDirection: Equatable {
    case up, down, left, right

    init(from translation: CGSize) {
        let absX = abs(translation.width)
        let absY = abs(translation.height)

        if absX > absY {
            self = translation.width > 0 ? .right : .left
        } else {
            self = translation.height > 0 ? .down : .up
        }
    }
}
