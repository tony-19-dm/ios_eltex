//
//  SupportTopicRepresentable.swift
//  Market
//
//  Created by Дмитриев Антон on 04.06.2026.
//

import Foundation
import SwiftUI
import UIKit

struct SupportTopicRepresentable: UIViewRepresentable {
    @Binding var selectedTopics: [String]

    func makeUIView(context: Context) -> SupportTopicView {
        let view = SupportTopicView()
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: SupportTopicView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedTopics: $selectedTopics)
    }

    final class Coordinator: NSObject, SupportTopicViewDelegate {
        @Binding var selectedTopics: [String]

        init(selectedTopics: Binding<[String]>) {
            self._selectedTopics = selectedTopics
        }

        func supportTopicView(_ view: SupportTopicView, didUpdateSelectedTopics topics: [String]) {
            selectedTopics = topics
        }
    }
}
