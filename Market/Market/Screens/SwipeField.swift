//
//  SwipeField.swift
//  Market
//
//  Created by Дмитриев Антон on 04.06.2026.
//

import Foundation
import SwiftUI

struct SwipeField: View {
    @Binding var highlightColor: Color
    let onSwipe: (SwipeDirection) -> Void

    @GestureState private var isDragging = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 16)
                .fill(highlightColor.opacity(isDragging ? 0.3 : 0))
                .animation(.easeInOut(duration: 0.15), value: isDragging)

            Image(systemName: "hand.draw")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onEnded { value in
                    let direction = SwipeDirection(from: value.translation)
                    onSwipe(direction)
                }
        )
    }
}
