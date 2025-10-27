import UIKit

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set}
    func viewDidLoad()
    func didTapLogout()
    func confirmLogout()
    func didReceiveAvatarUpdate()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    private let logoutService: ProfileLogoutServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let imageService: ProfileImageServiceProtocol

    init(
        view: ProfileViewControllerProtocol,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared,
        profileService: ProfileServiceProtocol = ProfileService.shared,
        imageService: ProfileImageServiceProtocol = ProfileImageService.shared
    ) {
        self.view = view
        self.logoutService = logoutService
        self.profileService = profileService
        self.imageService = imageService
    }
    
    func viewDidLoad() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(profile: profile as Any)
        didReceiveAvatarUpdate()
    }
    
    func didReceiveAvatarUpdate() {
        if let urlString = imageService.avatarURL,
           let url = URL(string: urlString) {
            view?.updateAvatar(url: url)
        }
    }
    
    func confirmLogout() {
        logoutService.logout(sender: UIButton())
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
}

