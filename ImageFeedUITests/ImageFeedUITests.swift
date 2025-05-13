import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        let app = XCUIApplication()
        app.launch()
        
        if app.otherElements["ImagesListView"].waitForExistence(timeout: 5) {

            let profileTab = app.tabBars.buttons["ProfileTab"]
            XCTAssertTrue(profileTab.waitForExistence(timeout: 3))
            profileTab.tap()
            
            let logoutButton = app.buttons["LogoutButton"]
            XCTAssertTrue(logoutButton.waitForExistence(timeout: 3))
            logoutButton.tap()
            
            let alert = app.alerts["Пока, пока!"]
            XCTAssertTrue(alert.waitForExistence(timeout: 3))
            alert.buttons["Да"].tap()
        }
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("seytsman@gmail.com")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        
        UIPasteboard.general.string = "DiMa320989MaShA"
        passwordTextField.press(forDuration: 1.0)
        
        let pasteMenuItem = app.menuItems["Paste"]
        XCTAssertTrue(pasteMenuItem.waitForExistence(timeout: 2))
        pasteMenuItem.tap()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        _ = tablesQuery.children(matching: .cell).element(boundBy: 0)
    }
    
    func testFeed() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UI-TESTING")
        app.launch()
        
        let tablesQuery = app.tables
        
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Первая ячейка не появилась")
        
        firstCell.swipeUp()
        
        let secondCell = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5), "Вторая ячейка не появилась")
        
        let likeOffButton = secondCell.buttons["like button off"]
        if likeOffButton.exists {
            likeOffButton.tap()
            
            let updatedCellAfterLike = tablesQuery.cells.element(boundBy: 1)
            let updatedLikeOnButton = updatedCellAfterLike.buttons["like button on"]
            XCTAssertTrue(updatedLikeOnButton.waitForExistence(timeout: 5), "Кнопка не переключилась в состояние 'лайк'")
        }
        
        let cellAfterLike = tablesQuery.cells.element(boundBy: 1)
        let likeOnButton = cellAfterLike.buttons["like button on"]
        if likeOnButton.exists {
            likeOnButton.tap()
            
            let updatedCellAfterDislike = tablesQuery.cells.element(boundBy: 1)
            let updatedLikeOffButton = updatedCellAfterDislike.buttons["like button off"]
            XCTAssertTrue(updatedLikeOffButton.waitForExistence(timeout: 5), "Кнопка не переключилась обратно в 'не лайк'")
        }
        
        secondCell.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Изображение не появилось")
        
        image.pinch(withScale: 2.5, velocity: 1.0)
        image.pinch(withScale: 0.5, velocity: -1.0)
        
        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
        backButton.tap()
        
        XCTAssertTrue(tablesQuery.cells.element(boundBy: 0).waitForExistence(timeout: 5), "Не вернулись к таблице после возврата назад")
    }
    
    
    
    func testProfile() throws {
        // тестируем сценарий профиля
    }
}
