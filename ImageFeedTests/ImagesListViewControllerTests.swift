
import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
    
    final class MockPresenter: ImagesListViewPresenterProtocol {
        var photos: [Photo] = [
            Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: nil,
                  welcomeDescription: "test", thumbImageURL: "", largeImageURL: "", isLiked: false)
        ]
        
        var viewDidLoadCalled = false
        var configureCellCalled = false
        var willDisplayCellCalled = false
        var didSelectCellCalled = false
        var didTapLikeCalled = false
        
        func viewDidLoad() {
            viewDidLoadCalled = true
        }
        
        @MainActor
        func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
            configureCellCalled = true
        }
        
        func willDisplayCell(at indexPath: IndexPath) {
            willDisplayCellCalled = true
        }
        
        func didSelectCell(at indexPath: IndexPath) {
            didSelectCellCalled = true
        }
        
        func didTapLike(_ cell: ImagesListCell, at indexPath: IndexPath) {
            didTapLikeCalled = true
        }
    }
    
    func testViewDidLoadCallsPresenter() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue((sut.presenter as! MockPresenter).viewDidLoadCalled)
    }
    
    func testTableViewNumberOfRows() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let rows = sut.tableView(sut.test_tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 1)
    }
    
    func testCellForRowConfiguresCell() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        sut.test_tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        _ = sut.tableView(sut.test_tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue((sut.presenter as! MockPresenter).configureCellCalled)
    }
    
    func testWillDisplayCellCallsPresenter() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let dummyCell = UITableViewCell()
        sut.tableView(sut.test_tableView, willDisplay: dummyCell, forRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue((sut.presenter as! MockPresenter).willDisplayCellCalled)
    }
    
    func testDidSelectRowCallsPresenterAndPerformsSegue() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        let navigation = UINavigationController(rootViewController: sut)
        UIApplication.shared.windows.first?.rootViewController = navigation
        sut.test_tableView.delegate?.tableView?(sut.test_tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue((sut.presenter as! MockPresenter).didSelectCellCalled)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ImagesListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let mock = MockPresenter()
        vc.presenter = mock
        return vc
    }
}
