import Foundation
import SwiftUI
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let storage: UserDefaults = .standard
    private let keyToken: String = "Bearer Token"
    private let keyUsername: String = "username"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: keyToken) ?? ""
        }
        set {
            KeychainWrapper.standard.set(newValue ?? "nil", forKey: keyToken)
            let isSet = KeychainWrapper.standard.string(forKey: keyToken) != nil
            guard isSet else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Could not save token to Keychain", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }
                return
            }
        }
    }
    
    var username: String? {
        get {
            KeychainWrapper.standard.string(forKey: keyUsername) ?? "NO USERNAME IN STORAGE"
        }
        set {
            KeychainWrapper.standard.set(newValue ?? "unable to save username", forKey: keyUsername)
            let isSet = KeychainWrapper.standard.string(forKey: keyUsername) != nil
            guard isSet else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Could not save username to Keychain", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                return
            }
        }
    }
    
    func isTokenValid() -> Bool {
        if let token = token {
            if token.isEmpty {
                return false
            } else {
                return true
            }
        }
        return false
    }
}
