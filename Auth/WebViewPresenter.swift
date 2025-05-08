import UIKit
@preconcurrency import WebKit

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        
        didUpdateProgressValue(0)
        
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
            guard let urlComponents = URLComponents(string: url.absoluteString) else {
                print ("Could not create URLComponents from \(url.absoluteString)")
                return nil
        }
        print(urlComponents.path)
        
        guard urlComponents.path == "/oauth/authorize/native" else {
            print("URL path does not match expected path: \(urlComponents.path)")
            return nil
        }
            guard let items = urlComponents.queryItems else {
                print("Missing query parameters")
                return nil
        }
            guard let codeItem = items.first(where: { $0.name == "code" }) else {
                print("Missing 'code' in query parameters")
                return nil
        }
        print("CODE:", codeItem.value as Any)
            return codeItem.value
    }
    
}
