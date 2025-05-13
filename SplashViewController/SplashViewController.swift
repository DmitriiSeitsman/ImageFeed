import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private var usernameInStorage = OAuth2TokenStorage.shared.username
    private var imageView = UIImageView()
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        if oauth2Service.oauth2TokenStorage.isTokenValid() {
            fetchProfile(oauth2TokenStorage.token)
            return
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController else { return }
            authViewController.delegate = self
            
            let navigationController = UINavigationController(rootViewController: authViewController)
            navigationController.navigationBar.isHidden = false
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupUI() {
        self.view.backgroundColor = .ypBlack
        let splashImage = UIImage(resource: .splashScreenLogo)
        imageView = UIImageView(image: splashImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 78)
        ])
    }
    
    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid Configuration")
                return
            }
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
            window.rootViewController = tabBarController
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        DispatchQueue.main.async {
            vc.dismiss(animated: true)
        }
        guard let token = oauth2TokenStorage.token else { return }
        fetchProfile(token)
    }
    
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.fetchOAuthToken(code)
            }
            
        }
    }
    
    static func showHUD() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    static func dismissHUD() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
    private func fetchProfile(_ token: String?) {
        assert(Thread.isMainThread)
        SplashViewController.showHUD()
        guard let token = token else { return }
        profileService.fetchProfile(token) { [weak self] result in
            SplashViewController.dismissHUD()
            guard let self = self else { return }
            switch result {
            case .success(let response):
                usernameInStorage = response.username
                switchToTabBarController()
            case .failure(let Error):
                print("Ошибка получения профиля \(Error)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ошибка", message:
"""
Не удалось получить данные профиля
причина: \(Error.localizedDescription)
""",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }
                break
            }
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                print("ОШИБКА в fetchOAuthToken SplashViewController")
                break
            }
        }
    }
}
