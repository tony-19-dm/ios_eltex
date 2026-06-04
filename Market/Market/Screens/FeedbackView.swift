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

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                TextField("Имя", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .name)
                    .onTapGesture {
                        viewModel.clearNameError()
                    }

                if let error = viewModel.nameError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                TextEditor(text: $viewModel.message)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray)
                    )
                    .focused($focusedField, equals: .message)
                    .onTapGesture {
                        viewModel.clearMessageError()
                    }

                if let error = viewModel.messageError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                SupportTopicRepresentable(selectedTopics: $viewModel.selectedTopics)
                    .frame(height: 220)

                Toggle(
                    isOn: $viewModel.isAgreementAccepted
                ) {
                    agreementText
                }

                Button("Отправить") {

                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSend)

                Spacer()
            }
            .padding()

            if showAgreement {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack {
                    ScrollView {
                        Text("""
                            Соглашение об обработке персональных данных

                            Тут должен быть ну оооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооооочень длинный текст...
                            """)
                        .padding()
                    }

                    Button("Закрыть") {
                        showAgreement = false
                    }
                }
                .frame(width: 320, height: 400)
                .background(.white)
                .cornerRadius(16)
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue == .name {
                viewModel.validateName()
            }

            if oldValue == .message {
                viewModel.validateMessage()
            }
        }
    }

    private var agreementText: some View {
        HStack(spacing: 0) {
            Text("Я согласен на ")

            Text("обработку данных")
                .foregroundColor(.blue)
                .onTapGesture {
                    showAgreement = true
                }
        }
    }
}

enum Field {
    case name
    case message
}
