import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController, AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        
    }
    
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    private static var window: UIWindow? {
            return UIApplication.shared.windows.first
        }
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AuthViewController loaded")
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.ypBlack
    }
    static func showHUD() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    static func dismissHUD() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        AuthViewController.showHUD()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] token in
            switch token {
            case .success(let result):
                DispatchQueue.main.async {
                    self?.delegate?.authViewController(self ?? AuthViewController(), didAuthenticateWithCode: code)
                    let splashVC = SplashViewController()
                    self?.present(splashVC, animated: true)
                }
                AuthViewController.dismissHUD()
                print("Result: \(result)")
            case .failure(let error):
                print("Error fetching token: \(error)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("webViewViewControllerDidCancel")
        vc.dismiss(animated: true)
    }
}
