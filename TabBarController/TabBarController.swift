import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let imagesListPresenter = ImagesListViewPresenter(view: imagesListViewController)
        imagesListViewController.presenter = imagesListPresenter
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenter(view: profileViewController)
        profileViewController.presenter = presenter
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        profileViewController.view.backgroundColor = .ypBlack
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
