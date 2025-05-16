import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
    }
    
    func testAuth() throws {
        let app = XCUIApplication()
        app.launch()
        
        let imagesListView = app.otherElements["ImagesListView"]
        let authButton = app.buttons["Authenticate"]
        
        if imagesListView.waitForExistence(timeout: 5) {
            print("Уже авторизованы — выходим из аккаунта")
            
            let profileTab = app.tabBars.buttons["ProfileTab"]
            XCTAssertTrue(profileTab.waitForExistence(timeout: 2))
            profileTab.tap()
            
            let logoutButton = app.buttons["LogoutButton"]
            XCTAssertTrue(logoutButton.waitForExistence(timeout: 2))
            logoutButton.tap()
            
            let alert = app.alerts["Пока, пока!"]
            XCTAssertTrue(alert.waitForExistence(timeout: 2))
            alert.buttons["Да"].tap()
        } else {
            print("Не авторизованы — начинаем логин")
        }
        
        XCTAssertTrue(authButton.waitForExistence(timeout: 3))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.textFields.element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("YOUREMAIL@HERE.COM")
        
        webView.swipeUp()
        
        let passwordTextField = webView.secureTextFields.element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("YOURPASSWORD")
        
        tapLoginButton(in: webView)
        
        let feedLoaded = imagesListView.waitForExistence(timeout: 10)
        XCTAssertTrue(feedLoaded, "Лента не появилась после логина")
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
        let app = XCUIApplication()
        app.launchArguments.append("UI-TESTING")
        app.launch()
        
        XCTAssertTrue(app.otherElements["ImagesListView"].waitForExistence(timeout: 5), "Экран ленты не загрузился")
        
        let profileTab = app.tabBars.buttons["ProfileTab"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 3), "Вкладка профиля не найдена")
        profileTab.tap()
        
        let nameLabel = app.staticTexts["userName"]
        let loginLabel = app.staticTexts["userLoginName"]
        let descriptionLabel = app.staticTexts["ProfileDescription"]
        let avatarImage = app.images["ProfileAvatar"]
        
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 3), "Имя пользователя не отображается")
        XCTAssertTrue(loginLabel.exists, "Логин не отображается")
        XCTAssertTrue(descriptionLabel.exists, "Описание не отображается")
        XCTAssertTrue(avatarImage.exists, "Аватар не отображается")
        
        let logoutButton = app.buttons["LogoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 3), "Кнопка выхода не найдена")
        logoutButton.tap()
        
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Алерт подтверждения выхода не появился")
        alert.buttons["Да"].tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Экран авторизации не появился после выхода")
    }
    // MARK: - Helpers
    func tapLoginButton(in webView: XCUIElement, timeout: TimeInterval = 5) {
        let exactLoginButton = webView.buttons["Login"]
        
        if exactLoginButton.exists {
            exactLoginButton.tap()
            print("Нажали на кнопку 'Login' по точному идентификатору")
        } else if let fallbackButton = webView.buttons.allElementsBoundByIndex.first(where: {
            $0.label.lowercased().contains("log")
        }) {
            fallbackButton.tap()
            print("Нажали на кнопку, содержащую 'log' в label: \(fallbackButton.label)")
        } else {
            let firstButton = webView.buttons.element(boundBy: 0)
            XCTAssertTrue(firstButton.waitForExistence(timeout: timeout), "Резервная кнопка входа не найдена")
            firstButton.tap()
            print("Нажали на первую найденную кнопку как последний вариант")
        }
    }

    
    
}
