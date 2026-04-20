//
//  SplashScreenViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 20.04.2026.
//

import Foundation
import UIKit

final class SplashScreenViewController: UIViewController {
    private let logo = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        animateLogo()
        openMainAfterDelay()
    }
}

private extension SplashScreenViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground

        logo.image = UIImage(resource: .trade)
        logo.tintColor = .systemMint
        logo.contentMode = .scaleAspectFit

        view.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: 120),
            logo.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}

private extension SplashScreenViewController {
    func animateLogo() {
        UIView.animate(
            withDuration: 1,
            delay: 0,
            options: [.repeat, .autoreverse],
            animations: {
                self.logo.alpha = 0.4
            }
        )
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = Double.pi * 2.0
        rotation.duration = 1.2
        rotation.repeatCount = .infinity
        
        logo.layer.add(rotation, forKey: "rotate")
    }
}

private extension SplashScreenViewController {
    func openMainAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {

            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate

            sceneDelegate?.window?.rootViewController =
                sceneDelegate?.openRootViewController()
        }
    }
}
