import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {
    // MARK: - Mocks
    final class MockPresenter: ProfileViewPresenterProtocol {
        var view: (any ImageFeed.ProfileViewControllerProtocol)?
        
        var viewDidLoadCalled = false
        var didTapLogoutCalled = false
        var didReceiveAvatarUpdateCalled = false
        var confirmLogoutCalled = false
        
        func viewDidLoad() {
            viewDidLoadCalled = true
        }
        
        func didTapLogout() {
            didTapLogoutCalled = true
        }
        
        func didReceiveAvatarUpdate() {
            didReceiveAvatarUpdateCalled = true
        }
        
        func confirmLogout() {
            confirmLogoutCalled = true
        }
    }
    // MARK: - Tests
    func testViewDidLoadCallsPresenter() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue((sut.presenter as! MockPresenter).viewDidLoadCalled)
    }
    
    func testLogoutButtonTriggersPresenter() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let button = sut.view.subviews.compactMap { $0 as? UIButton }.first
        button?.sendActions(for: .touchUpInside)
        XCTAssertTrue((sut.presenter as! MockPresenter).didTapLogoutCalled)
    }
    
    func testUpdateProfileDetailsUpdatesUI() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let profile: Profile? = Profile(username: "ekaterinanovikova",
                                        firstName: "Екатерина",
                                        lastName: "Новикова",
                                        name: "testName",
                                        loginName: "testLoginName",
                                        bio: "testBio",
                                        profileImageURL: "testURL")
        sut.updateProfileDetails(profile: profile as Any)
        XCTAssertEqual(sut.userNameLabel.text, "Екатерина Новикова")
        XCTAssertEqual(sut.loginNameLabel.text, "@ekaterinanovikova")
        XCTAssertEqual(sut.descriptionLabel.text, "Hello World!")
        
    }
    
    func testShowLogoutAlertPresentsAlert() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        
        sut.showLogoutAlert()
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        
        let presented = sut.presentedViewController as? UIAlertController
        XCTAssertNotNil(presented)
        XCTAssertEqual(presented?.title, "Пока, пока!")
    }
    
    // MARK: - Helpers
    private func makeSUT() -> ProfileViewController {
        let vc = ProfileViewController()
        let presenter = MockPresenter()
        vc.presenter = presenter
        return vc
    }
}
