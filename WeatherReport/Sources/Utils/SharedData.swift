//
//  SharedData.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import Foundation
import KeychainAccess

final class SharedData {
    static let shared = SharedData()

    let defaults: UserDefaults
    let keychain: Keychain

    private init() {
        #if DEBUG
            defaults = UserDefaults(suiteName: "jp.ooyasora.WeatherReport.Debug")!
        #elseif TEST
            defaults = UserDefaults(suiteName: "jp.ooyasora.WeatherReport.Tests")!
        #else
            defaults = .standard
        #endif
        keychain = Keychain()
    }
}

// MARK: - DataStore

protocol DataStore: AnyObject {
    func string(_ key: String) -> String?
    func integer(_ key: String) -> Int
    func bool(_ key: String) -> Bool
    func array(_ key: String) -> [Any]?
    func data(_ key: String) -> Data?
    func object(_ key: String) -> Any?
    func set(_ newValue: Any?, forKey: String)
    func removeObject(for key: String)
    func removeAllObjects()
}

extension SharedData: DataStore {
    func string(_ key: String) -> String? {
        defaults.string(forKey: key)
    }

    func integer(_ key: String) -> Int {
        defaults.integer(forKey: key)
    }

    func bool(_ key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func array(_ key: String) -> [Any]? {
        defaults.array(forKey: key)
    }

    func data(_ key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func object(_ key: String) -> Any? {
        defaults.object(forKey: key)
    }

    func set(_ newValue: Any?, forKey: String) {
        defaults.set(newValue, forKey: forKey)
    }

    func removeObject(for key: String) {
        defaults.removeObject(forKey: key)
    }

    func removeAllObjects() {
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.synchronize()
    }
}

// MARK: -

protocol SecuredDataStore: AnyObject {
    func credential(_ key: String) -> String?
    func store(credential newValue: String?, for key: String)
    func remove(credential key: String)
    func removeAllCredentials()
}

extension SharedData: SecuredDataStore {
    func credential(_ key: String) -> String? {
        keychain[key]
    }

    func store(credential newValue: String?, for key: String) {
        keychain[key] = newValue
    }

    func remove(credential key: String) {
        try? keychain.remove(key)
    }

    func removeAllCredentials() {
        try? keychain.removeAll()
    }
}

// MARK: - APIToken

extension SecuredDataStore {
    var apiKey: String? {
        get {
            guard let apiToken = credential("apiKey") else {
                return nil
            }
            return apiToken
        }
        set {
            store(credential: newValue, for: "apiKey")
        }
    }
}
