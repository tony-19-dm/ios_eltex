//
//  SceneDelegate.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = SplashScreenViewController()
        
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    func openRootViewController() -> UIViewController {
        let wallet = Wallet()
        
        let tabBarController = UITabBarController()
        
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
        
        tabBarController.viewControllers = [historyNavigationController, graphNavigationController]
        
        return tabBarController
    }
}

