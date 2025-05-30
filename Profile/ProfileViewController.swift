import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateProfileDetails(profile: Any)
    func updateAvatar(url: URL)
    func showLogoutAlert()
}

final class ProfileViewController: UIViewController {
    
    var presenter: ProfileViewPresenterProtocol?
    
    var imageView = UIImageView()
    let loginNameLabel = UILabel()
    let userNameLabel = UILabel()
    let descriptionLabel = UILabel()
    
    private var image: UIImage?
    private var authToken = OAuth2TokenStorage.shared.token
    private var usernameInStorage = OAuth2TokenStorage.shared.username
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "ProfileView"
        presenter?.viewDidLoad()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                presenter?.didReceiveAvatarUpdate()
            }
        
        setupUI()
        configureuserNameLabel(userNameLabel, text: "Екатерина Новикова", fontSize: 23, color: .ypWhite)
        configureLoginNameLabel(loginNameLabel, text: "@ekaterinanovikova", fontSize: 13, color: .ypGray)
        configureDescriptionLabel(descriptionLabel, text: "Hello World!", fontSize: 13, color: .ypWhite)
    }
    
    @objc private func logoutButtonClick(){
        presenter?.didTapLogout()
    }
    
    private func setupUI() {
        let profileImage = UIImage(named: "Photo")
        imageView = UIImageView(image: profileImage)
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.accessibilityIdentifier = "ProfileAvatar"
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
        ])
        
        let image = UIImage(resource: .exit)
        let button = UIButton.systemButton(
            with: image,
            target: self,
            action: nil
        )
        button.addTarget(self, action: #selector(logoutButtonClick), for: .touchUpInside)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        button.accessibilityIdentifier = "LogoutButton"
        
    }
    
    private func configureuserNameLabel(_ nameLabel: UILabel, text: String, fontSize: CGFloat, color: UIColor) {
        nameLabel.text = text
        nameLabel.font = .systemFont(ofSize: fontSize, weight: .bold)
        nameLabel.textColor = color
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110).isActive = true
        nameLabel.accessibilityIdentifier = "userName"
    }
    
    private func configureLoginNameLabel(_ loginNameLabel: UILabel, text: String, fontSize: CGFloat, color: UIColor) {
        loginNameLabel.text = text
        loginNameLabel.font = .systemFont(ofSize: fontSize, weight: .medium)
        loginNameLabel.textColor = color
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
        loginNameLabel.accessibilityIdentifier = "userLoginName"
    }
    
    private func configureDescriptionLabel(_ descriptionLabel: UILabel, text: String, fontSize: CGFloat, color: UIColor) {
        descriptionLabel.text = text
        descriptionLabel.font = .systemFont(ofSize: fontSize, weight: .medium)
        descriptionLabel.textColor = color
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.accessibilityIdentifier = "ProfileDescription"
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
}

extension ProfileViewController: ProfileViewControllerProtocol {
    func updateProfileDetails(profile: Any) {
        let profile = profile as? Profile
        guard let profile else { return }
        DispatchQueue.main.async { [self] in
            userNameLabel.text = "\(profile.firstName) \(profile.lastName)"
            loginNameLabel.text = "@\(profile.username)"
            descriptionLabel.text = profile.bio
        }
    }
    
    func updateAvatar(url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 35, targetSize: CGSize(width: 70, height: 70), backgroundColor: .clear)
        imageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder.png"), options: [.processor(processor)]) { _ in
            self.imageView.backgroundColor = .clear
            self.imageView.layer.masksToBounds = true
        }
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.presenter?.confirmLogout()
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}
