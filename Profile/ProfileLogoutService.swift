import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private var oAuth2TokenStorage = OAuth2TokenStorage()
    
    private init() { }
    
    @objc func logout(sender: UIButton) {
        cleanCookies()
        oAuth2TokenStorage.clearStorage()
        ProfileService.shared.clearData()
        ImagesListService().clearData()
        let splashVC = SplashViewController()
        splashVC.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController?.present(splashVC, animated: true, completion: nil)
        
        print("ACTUAAL TOKEN:", oAuth2TokenStorage.token ?? "NO TOKEN IN STORAGE ANYMORE")
        print("ACTUAL USERNAME:", oAuth2TokenStorage.username ?? "NO USERNAME IN STORAGE ANYMORE")
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
