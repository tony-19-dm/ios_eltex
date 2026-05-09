//
//  Coordinator.swift
//  Market
//
//  Created by Дмитриев Антон on 09.05.2026.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
