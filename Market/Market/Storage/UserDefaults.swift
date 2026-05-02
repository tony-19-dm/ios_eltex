//
//  UserDefaults.swift
//  Market
//
//  Created by Дмитриев Антон on 02.05.2026.
//

import Foundation

final class Defaults {
    static let shared = Defaults()
    private let defaults = UserDefaults.standard
    
    var login: String? {
        get {
            defaults.string(forKey: Keys.login)
        }
        set {
            defaults.set(newValue, forKey: Keys.login)
        }
    }
    
    var password: String? {
        get {
            defaults.string(forKey: Keys.password)
        }
        set {
            defaults.set(newValue, forKey: Keys.password)
        }
    }
    
    var isAutoLogin: Bool {
        get {
            defaults.bool(forKey: Keys.isAutoLogin)
        }
        set {
            defaults.set(newValue, forKey: Keys.isAutoLogin)
        }
    }
    
    func clearUserData() {
        defaults.removeObject(forKey: Keys.login)
        defaults.removeObject(forKey: Keys.password)
    }
}

private enum Keys {
    static let login = "login"
    static let password = "password"
    static let isAutoLogin = "isAutoLogin"
}
