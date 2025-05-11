@testable import ImageFeed
import XCTest

final class ProfileViewPresenterTests: XCTestCase {

    // MARK: - Mocks

    final class MockView: ProfileViewControllerProtocol {
        var presenter: ProfileViewPresenterProtocol?
        var didUpdateProfile = false
        var didUpdateAvatar = false
        var didShowLogoutAlert = false

        func updateProfileDetails(profile: Any) {
            print("✅ updateProfileDetails called")
            didUpdateProfile = true
        }

        func updateAvatar(url: URL) {
            print("✅ updateAvatar called")
            didUpdateAvatar = true
        }

        func showLogoutAlert() {
            didShowLogoutAlert = true
        }
    }

    final class MockLogoutService: ProfileLogoutServiceProtocol {
        var logoutCalled = false

        func logout(sender: UIButton) {
            logoutCalled = true
        }
    }
    
    final class MockImageService: ProfileImageServiceProtocol {
        var avatarURL: String? = "https://example.com/avatar.png"
    }
    
    final class MockProfileService: ProfileServiceProtocol {
        var profile: Profile? = Profile(username: "testUserName",
                                        firstName: "testFirstName",
                                        lastName: "testLastName",
                                        name: "testName",
                                        loginName: "testLoginName",
                                        bio: "testBio",
                                        profileImageURL: "testURL")
    }


    // MARK: - Tests

    func test_viewDidLoad_updatesProfileAndAvatar() {
        let view = MockView()
        let profileService = MockProfileService()
        let imageService = MockImageService()
        let presenter = ProfileViewPresenter(
            view: view,
            profileService: profileService,
            imageService: imageService
        )
        view.presenter = presenter
        presenter.viewDidLoad()

        XCTAssertTrue(view.didUpdateProfile, "Presenter should update profile details on viewDidLoad.")
        XCTAssertTrue(view.didUpdateAvatar, "Presenter should update avatar on viewDidLoad.")
    }

    func test_didTapLogout_showsLogoutAlert() {
        let view = MockView()
        let presenter = ProfileViewPresenter(view: view)
        view.presenter = presenter

        presenter.didTapLogout()

        XCTAssertTrue(view.didShowLogoutAlert, "Presenter should request logout alert on didTapLogout.")
    }

    func test_confirmLogout_callsLogoutService() {
        let view = MockView()
        let logoutService = MockLogoutService()
        let presenter = ProfileViewPresenter(view: view, logoutService: logoutService)

        presenter.confirmLogout()

        XCTAssertTrue(logoutService.logoutCalled, "Presenter should call logout on logoutService.")
    }

}
