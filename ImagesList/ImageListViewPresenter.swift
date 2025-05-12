import UIKit
import Kingfisher
import ProgressHUD

protocol ImagesListViewPresenterProtocol {
    var photos: [Photo] { get }
    @MainActor func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath)
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func didSelectCell(at: IndexPath)
    func didTapLike(_ cell: ImagesListCell, at indexPath: IndexPath)
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    private var imagesListService: ImagesListServiceProtocol
    private let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    var photos: [Photo] {
        imagesListService.photosFull
    }
    
    init(view: ImagesListViewControllerProtocol,
         imagesListService: ImagesListServiceProtocol = ImagesListService()) {
        self.view = view
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handlePhotosUpdated(notification)
        }
        loadPhotos()
    }
    
    @MainActor func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let url = URL(string: photo.thumbImageURL)
        let size = resize(cellWidth: cell.bounds.width, photo: photo)
        
        let processor = ResizingImageProcessor(referenceSize: size)
        let placeholder = UIImage(resource: .tableViewPlaceholder)
        
        cell.cellImage.kf.setImage(with: url, placeholder: placeholder, options: [.processor(processor)]) { _ in
            self.view?.reloadRows(at: [indexPath])
        }
        
        cell.dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        let likeImage = photo.isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            loadPhotos()
        }
    }
    
    func didSelectCell(at: IndexPath) {
        
    }
    
    func didTapLike(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let newLikeState = !photo.isLiked
        
        ProgressHUD.animate()
        cell.likeButton.isUserInteractionEnabled = false
        cell.isUserInteractionEnabled = false
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("LIKE CHANGED")
                    ProgressHUD.dismiss()
                    cell.likeButton.isUserInteractionEnabled = true
                    cell.isUserInteractionEnabled = true
                    self?.view?.reloadRows(at: [indexPath])
                case .failure:
                    print("LIKE WAS NOT CHANGED")
                    ProgressHUD.dismiss()
                    cell.likeButton.isUserInteractionEnabled = true
                    cell.isUserInteractionEnabled = true
                    self?.view?.showLikeErrorAlert()
                }
            }
        }
        imagesListService.task = nil
    }
    
    private func loadPhotos() {
        let oldCount = photos.count
        imagesListService.fetchPhotosNextPage { [weak self] result in
            switch result {
            case .success(let photoResponses):
                guard let self else { return }
                for response in photoResponses {
                    let photo = self.imagesListService.convertPhotosStruct(response: response)
                    self.imagesListService.photosFull.append(photo)
                }
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["photosFull": oldCount]
                )
            case .failure(let error):
                print("FAILED TO LOAD PHOTOS:", error)
            }
        }
    }
    
    private func resize(cellWidth: CGFloat, photo: Photo) -> CGSize {
        let width = cellWidth - imageInsets.left - imageInsets.right
        let scale = width / photo.size.width
        let height = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return CGSize(width: width, height: height)
    }
    
    private func handlePhotosUpdated(_ notification: Notification) {
        guard
            let oldCount = notification.userInfo?.values.first as? Int
        else { return }
        
        let newCount = photos.count
        guard oldCount != newCount else { return }
        
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        view?.insertRows(at: indexPaths)
    }
    
}
