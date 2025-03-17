import UIKit

final class ProfileViewController: UIViewController {
    
    private var imageView = UIImageView()
    private let loginNameLabel = UILabel()
    private let userNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureuserNameLabel(userNameLabel, text: "Екатерина Новикова", fontSize: 23, color: .ypWhite)
        configureLoginNameLabel(loginNameLabel, text: "@ekaterinanovikova", fontSize: 13, color: .ypGray)
        configureDescriptionLabel(descriptionLabel, text: "Hello World!", fontSize: 13, color: .ypWhite)
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
