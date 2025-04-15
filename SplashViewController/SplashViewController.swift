import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    var imageView = UIImageView()
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileViewController = ProfileViewController()
    private var usernameInStorage = OAuth2TokenStorage().username
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        if oauth2Service.oauth2TokenStorage.isTokenValid() {
            fetchProfile(oauth2TokenStorage.token)
            switchToTabBarController()
            return
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let viewController = storyboard.instantiateViewController(
                withIdentifier: "navigationController"
            )
            viewController.navigationController?.navigationBar.isHidden = false
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
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
        let splashImage = UIImage(named: "splash_screen_logo")
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
        guard let window = UIApplication.shared.windows.first else { assertionFailure("Invalid Configuration"); return }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        dismiss(animated: true)
        guard let token = oauth2TokenStorage.token else { return }
        fetchProfile(token)
    }
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
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
        SplashViewController.showHUD()
        guard let token = token else { return }
        profileService.fetchProfile(token) { [weak self] result in
            SplashViewController.dismissHUD()
            switch result {
            case .success:
                guard let self = self else { return }
                self.switchToTabBarController()
            case .failure:
                print("Ошибка получения профиля \(result)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось получить данные профиля", preferredStyle: .alert)
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
