//
//  HeatmapViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 27.05.2026.
//

import Foundation
import UIKit
import SwiftUI

final class HeatmapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Heatmap"
        view.backgroundColor = .systemBackground

        let swiftUIView = UIHostingController(
            rootView: Heatmap()
        )

        addChild(swiftUIView)

        view.addSubview(swiftUIView.view)

        swiftUIView.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            swiftUIView.view.topAnchor.constraint(equalTo: view.topAnchor),
            swiftUIView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swiftUIView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            swiftUIView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        swiftUIView.didMove(toParent: self)
    }
}
