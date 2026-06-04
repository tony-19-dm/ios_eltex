//
//  BotCheckView.swift
//  Market
//
//  Created by Дмитриев Антон on 04.06.2026.
//

import Foundation
import SwiftUI

struct BotCheckView: View {
    let onSuccess: () -> Void
    let onFailure: () -> Void

    @StateObject private var vm = BotCheckViewModel()

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Подтверждение личности")
                    .font(.title2.bold())

                Text("Шаг \(vm.currentStep + 1) из \(vm.totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                VStack(spacing: 6) {
                    Text("Следующая команда:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(vm.currentCommand.label)
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal:   .move(edge: .leading).combined(with: .opacity)
                            )
                        )
                        .id(vm.currentStep)
                }

                SwipeField(highlightColor: $vm.highlightColor) { direction in
                    vm.handleSwipe(direction)
                }
                .frame(width: 260, height: 260)
                .cornerRadius(16)
            }
            .padding(24)
            .frame(width: 320)
            .background(.background)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 20)
        }
        .onChange(of: vm.result) { _, result in
            guard let result else { return }
            switch result {
            case .success: onSuccess()
            case .failure: onFailure()
            }
        }
        .alert(vm.alertTitle, isPresented: $vm.showAlert) {
            Button("OK") { vm.handleAlertDismiss() }
        } message: {
            Text(vm.alertMessage)
        }
    }
}
