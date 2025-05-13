
import XCTest
@testable import ImageFeed

final class ImagesListViewPresenterTests: XCTestCase {
    // MARK: - Mocks
    final class MockView: ImagesListViewControllerProtocol {
        var reloadRowsCalled = false
        var insertRowsCalled = false
        var showLikeErrorAlertCalled = false
        var insertedIndexPaths: [IndexPath] = []
        
        func cellAt(indexPath: IndexPath) -> ImagesListCell? {
            return nil
        }

        
        func reloadRows(at indexPaths: [IndexPath]) {
            reloadRowsCalled = true
        }
        
        func insertRows(at indexPaths: [IndexPath]) {
            insertRowsCalled = true
            insertedIndexPaths = indexPaths
        }
        
        func showLikeErrorAlert() {
            showLikeErrorAlertCalled = true
        }
    }
    
    final class StubImagesListService: ImagesListServiceProtocol {
        var task: URLSessionTask?
        var photosFull: [Photo] = []
        var fetchPhotosCalled = false
        
        var changeLikeCallback: ((String, Bool, @escaping (Result<[Photo], Error>) -> Void) -> Void)?
        
        func fetchPhotosNextPage(handler: @escaping (Result<[photoPackResponse], Error>) -> Void) {
            fetchPhotosCalled = true
            handler(.success([]))
        }
        
        func convertPhotosStruct(response: photoPackResponse) -> Photo {
            return Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil,
                         welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", isLiked: false)
        }
        
        func changeLike(photoId: String, isLike: Bool, _ handler: @escaping (Result<[Photo], Error>) -> Void) {
            if let callback = changeLikeCallback {
                callback(photoId, isLike, handler)
            } else {
                handler(.success([]))
            }
        }
        
        func clearData() {
            photosFull.removeAll()
        }
    }
    // MARK: - Tests
    func testViewDidLoadTriggersFetch() {
        let view = MockView()
        let service = StubImagesListService()
        let presenter = ImagesListViewPresenter(view: view, imagesListService: service)
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(service.fetchPhotosCalled, "Должен вызываться fetchPhotosNextPage")
    }
    
    func testHandlePhotosUpdatedInsertsRows() {
        let view = MockView()
        let service = StubImagesListService()
        let presenter = ImagesListViewPresenter(view: view, imagesListService: service)
        
        let oldCount = 0
        service.photosFull = [
            Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil,
                  welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", isLiked: false)
        ]
        
        presenter.viewDidLoad()
        
        let expectation = expectation(description: "Notification handled")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                            object: presenter,
                                            userInfo: ["photosFull": oldCount])
            
            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(view.insertRowsCalled)
        XCTAssertEqual(view.insertedIndexPaths, [IndexPath(row: 0, section: 0)])
    }
    
    
    func testConfigureCell() async {
        let view = MockView()
        let service = StubImagesListService()
        let presenter = ImagesListViewPresenter(view: view, imagesListService: service)
        
        let photo = Photo(id: "123",
                          size: CGSize(width: 100, height: 200),
                          createdAt: Date(),
                          welcomeDescription: "desc",
                          thumbImageURL: "https://example.com/thumb.jpg",
                          largeImageURL: "https://example.com/large.jpg",
                          isLiked: true)
        
        service.photosFull = [photo]
        
        XCTAssertEqual(service.photosFull.count, 1, "Service photosFull должен содержать 1 фото")
        XCTAssertEqual(presenter.photos.count, 1, "Presenter.photos должен содержать 1 фото")
        
        let cell: ImagesListCell = await MainActor.run {
            let cell = ImagesListCell()
            cell.frame.size.width = 300
            return cell
        }
        
        guard presenter.photos.indices.contains(0) else {
            XCTFail("Нет фото по indexPath для configureCell")
            return
        }
        print("photos.count: \(presenter.photos.count), indexPath: \(IndexPath(row: 0, section: 0))")
        XCTAssertFalse(presenter.photos.isEmpty, "Массив фото не должен быть пустым")
        
        let imageView = await UIImageView()
        let label = await UILabel()
        let button = await UIButton()
        
        await MainActor.run {
            cell.cellImage = imageView
            cell.dateLabel = label
            cell.likeButton = button
        }
        
        await presenter.configureCell(cell, at: IndexPath(row: 0, section: 0))
        
        let text = await MainActor.run { cell.dateLabel.text }
        XCTAssertEqual(text?.isEmpty, false)
        
        let image = await MainActor.run { cell.likeButton.image(for: .normal) }
        XCTAssertEqual(image, UIImage(resource: .likeButtonOn))
    }
    
}
