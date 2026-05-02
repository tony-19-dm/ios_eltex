//
//  SceneDelegate.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    let defaults = Defaults.shared
    
    let wallet = Wallet()
    
    let tabBarController = UITabBarController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = SplashScreenViewController()
        
        window.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    func setup() {
        if defaults.isAutoLogin,
           defaults.login != nil,
           defaults.password != nil {
            showMainApp()
        } else {
            showAuth()
        }
    }

    func showAuth() {
        let vc = AuthViewController()
        vc.onSuccessLogin = { [weak self] in
            self?.showMainApp()
        }

        window?.rootViewController = vc
    }

    func showMainApp() {
        window?.rootViewController = createTabBar()
    }
}

extension SceneDelegate {
    func openRootViewController() {
        setup()
    }
    
    func createTabBar() -> UITabBarController {
        let historyViewController = HistoryViewController(wallet: wallet)
        historyViewController.title = "История"
        let historyNavigationController = UINavigationController(rootViewController: historyViewController)
        historyNavigationController.tabBarItem = UITabBarItem(
            title: "История",
            image: UIImage(systemName: "book"),
            tag: 0
        )
        
        let graphViewController = GraphViewController()
        graphViewController.title = "График"
        let graphNavigationController = UINavigationController(rootViewController: graphViewController)
        graphNavigationController.tabBarItem = UITabBarItem(
            title: "График",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            tag: 1
        )
        
        let settingsViewController = SettingsViewController()
        settingsViewController.title = "Настройки"
        settingsViewController.onLogout = { [weak self] in
            self?.showAuth()
        }
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        settingsNavigationController.tabBarItem = UITabBarItem(
            title: "Настройки",
            image: UIImage(systemName: "transmission"),
            tag: 2
        )
        
        tabBarController.viewControllers = [historyNavigationController, graphNavigationController, settingsNavigationController]
        
        return tabBarController
    }
}

