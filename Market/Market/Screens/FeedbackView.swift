//
//  FeedbackView.swift
//  Market
//
//  Created by Дмитриев Антон on 04.06.2026.
//

import Foundation
import SwiftUI

struct FeedbackView: View {
    @StateObject private var viewModel = FeedbackViewModel()
    @FocusState private var focusedField: Field?
    @State private var showAgreement = false
    @State private var showBotCheck = false

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                TextField("Имя", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .name)
                    .onTapGesture { viewModel.clearNameError() }

                errorLabel(viewModel.nameError)

                TextEditor(text: $viewModel.message)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray)
                    )
                    .focused($focusedField, equals: .message)
                    .onTapGesture { viewModel.clearMessageError() }

                errorLabel(viewModel.messageError)

                SupportTopicRepresentable(selectedTopics: $viewModel.selectedTopics)
                    .frame(height: 220)

                Toggle(isOn: $viewModel.isAgreementAccepted) {
                    agreementText
                }

                Button("Отправить") {
                    showBotCheck = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSend)
                .animation(.easeInOut(duration: 0.25), value: viewModel.canSend)
                .scaleEffect(viewModel.canSend ? 1.0 : 0.97)

                Spacer()
            }
            .padding()

            if showAgreement {
                agreementOverlay
            }

            if showBotCheck {
                BotCheckView(
                    onSuccess: {
                        showBotCheck = false
                        viewModel.resetForm()
                    },
                    onFailure: {
                        showBotCheck = false
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showBotCheck)
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue == .name    { viewModel.validateName() }
            if oldValue == .message { viewModel.validateMessage() }
        }
        .navigationTitle("Обратная связь")
    }

    @ViewBuilder
    private func errorLabel(_ text: String?) -> some View {
        if let text {
            Text(text)
                .foregroundColor(.red)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(
                    .asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal:   .push(from: .bottom).combined(with: .opacity)
                    )
                )
        }
    }

    private var agreementText: some View {
        HStack(spacing: 0) {
            Text("Я согласен на ")
            Text("обработку данных")
                .foregroundColor(.blue)
                .onTapGesture { showAgreement = true }
        }
    }

    private var agreementOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showAgreement = false }

            VStack {
                ScrollView {
                    Text("""
                        Соглашение об обработке персональных данных

                        Тут должен быть ну оооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооочень длинный текст...
                        """)
                    .padding()
                }
                Button("Закрыть") { showAgreement = false }
                    .padding(.bottom)
            }
            .frame(width: 320, height: 400)
            .background(.background)
            .cornerRadius(16)
        }
        .transition(.opacity)
    }
}

enum Field: Hashable {
    case name
    case message
}
