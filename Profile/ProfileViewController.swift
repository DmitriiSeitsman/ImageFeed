import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    var imageView = UIImageView()
    let loginNameLabel = UILabel()
    let userNameLabel = UILabel()
    let descriptionLabel = UILabel()
    
    private var authToken = OAuth2TokenStorage.shared.token
    private var usernameInStorage = OAuth2TokenStorage.shared.username
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
                self.updateProfileDetails(profile: ProfileService.shared.profile)
            }
        
        setupUI()
        configureuserNameLabel(userNameLabel, text: "Екатерина Новикова", fontSize: 23, color: .ypWhite)
        configureLoginNameLabel(loginNameLabel, text: "@ekaterinanovikova", fontSize: 13, color: .ypGray)
        configureDescriptionLabel(descriptionLabel, text: "Hello World!", fontSize: 13, color: .ypWhite)
        updateAvatar()

        updateProfileDetails(profile: ProfileService.shared.profile)
    }
    
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else { return }
        DispatchQueue.main.async { [self] in
            userNameLabel.text = "\(profile.firstName) \(profile.lastName)"
            loginNameLabel.text = "@\(profile.username)"
            descriptionLabel.text = profile.bio
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        DispatchQueue.main.async {
            let processor = RoundCornerImageProcessor(cornerRadius: 35)
            self.imageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder.png"), options: [.processor(processor)]) {_ in 
            }
        }
    }
    
    @objc private func buttonClick(){

        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        let logoutAction: UIAlertAction = UIAlertAction(title: "Да", style: .destructive) { (_) in
            ProfileLogoutService.shared.logout(sender: UIButton())
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Нет", style: .cancel)
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        
    }
    
    private func setupUI() {
        let profileImage = UIImage(named: "Photo")
        imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
        ])
        
        let button = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: self,
            action: nil
        )
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        
        
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
    private func configureuserNameLabel(_ label: UILabel, text: String, fontSize: CGFloat, color: UIColor) {
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: .bold)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110).isActive = true
    }
    
    private func configureLoginNameLabel(_ label: UILabel, text: String, fontSize: CGFloat, color: UIColor) {
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: .medium)
        loginNameLabel.textColor = color
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        loginNameLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func configureDescriptionLabel(_ label: UILabel, text: String, fontSize: CGFloat, color: UIColor) {
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: .medium)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
    }
}
