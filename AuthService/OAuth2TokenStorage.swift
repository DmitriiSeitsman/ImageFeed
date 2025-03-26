import Foundation

final class OAuth2TokenStorage {
    
    private let storage: UserDefaults = .standard
    private let key: String = "Bearer Token"
    
    var token: String {
        get {
            storage.string(forKey: key) ?? ""
        }
        set {
            storage.set(newValue, forKey: key)
        }
    }
    
    func isTokenValid() -> Bool {
        if token.isEmpty {
            return false
        } else {
            return true
        }
    }
}
