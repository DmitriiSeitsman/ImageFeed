import UIKit
import Kingfisher


final class ImagesListViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    
    private var imageView = UIImageView()
    private var photosServiceObserver: NSObjectProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    private var wasLiked: Bool = false
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        photosServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] arrayCount in
                guard let self = self else { return }
                guard let arrayCount = arrayCount.userInfo?.values.first else { return }
                var arrayCountUnwrapped: [Photo] = arrayCount as! [Photo]
                updateTableViewAnimated(photos: &arrayCountUnwrapped)
            }
        tableView.reloadData()
        loadPhotos()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: segue, sender: sender)
            return
        }
        let image = imagesListService.photosFull[indexPath.row]
        let url = URL(string: String(image.largeImageURL))
        viewController.url = url
    }
    
    
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imagesListService.photosFull[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imagesListService.photosFull[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    private func resize ( _ tableView: UITableView, indexPath: IndexPath) -> CGSize {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imagesListService.photosFull[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imagesListService.photosFull[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return CGSize(width: imageViewWidth, height: cellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    
    private func loadPhotos() {
        print("START LOADING PHOTOS")
        print("ARRAY OF PHOTOS BEFORE LOADING NEW PAGE", imagesListService.photosFull.count)
        let arrayCount = imagesListService.photosFull
        ImagesListService().fetchPhotosNextPage() { [weak self] result in
            switch result  {
            case .success:
                
                let photosCount = try! result.get().count
                for photos in 0..<photosCount {
                    self?.imagesListService.photosFull.append(self?.imagesListService.convertPhotosStruct(response: try! result.get()[photos]) ?? [] as! Photo
                    )}
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photosFull.count": arrayCount])
                print("ARRAY COUNT AFTER", self?.imagesListService.photosFull.count as Any)
                self?.tableView.reloadData()
                
            case .failure(let error):
                print("FAILED TO LOAD PHOTOS", error.localizedDescription)
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesListService.photosFull.count
    }
    
    func updateTableViewAnimated(photos: inout Array<Photo>) {
        if photos.isEmpty {
            return
        }
        let oldCount = photos.count
        let newCount = imagesListService.photosFull.count
        photos = imagesListService.photosFull
        print("OLD COUNT: \(oldCount) NEW COUNT: \(newCount)")
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let photosCount = imagesListService.photosFull.count
        if indexPath.row == photosCount - 1 {
            loadPhotos()
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        if imagesListService.photosFull.isEmpty == true { return }
        
        let image = imagesListService.photosFull[indexPath.row]
        let url = URL(string: String(image.thumbImageURL))
        
        let placeholderImage = UIImage(named: "table_view_placeholder")
        cell.cellImage.contentMode = .center
        cell.cellImage.backgroundColor = .ypGray
        let size: CGSize = resize(tableView, indexPath: indexPath)
        let processor = ResizingImageProcessor(referenceSize: size)
        cell.cellImage.kf.setImage(with: url, placeholder: placeholderImage, options: [.processor(processor)])
        
        guard let date = image.createdAt as Date? else { return }
        cell.dateLabel.text = dateFormatter.string(from: date)
        
        let isLiked = image.isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = imagesListService.photosFull[indexPath.row]
        let like = photo.isLiked
        
        if like == true {
            print("Was Liked")
            let likeImage = UIImage(named: "like_button_off")
            cell.likeButton.setImage(likeImage, for: .normal)
            wasLiked = true
        } else {
            print("Was Not Liked")
            let likeImage = UIImage(named: "like_button_on")
            cell.likeButton.setImage(likeImage, for: .normal)
            wasLiked = false
        }
        cell.likeButton.isUserInteractionEnabled = false
        
        imagesListService.changeLike(photoId: photo.id, isLike: like) { response in
            switch response {
            case .success(_):
                print("LIKE CHANGED")
                cell.likeButton.isUserInteractionEnabled = true
            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось изменить лайк", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }
                print("LIKE WAS NOT CHANGED, REASON:", error)
                if self.wasLiked == true {
                    let likeImage = UIImage(named: "like_button_off")
                    cell.likeButton.setImage(likeImage, for: .normal)
                } else {
                    let likeImage = UIImage(named: "like_button_on")
                    cell.likeButton.setImage(likeImage, for: .normal)
                }

                cell.likeButton.isUserInteractionEnabled = true
            }
        }
        cell.likeButton.isUserInteractionEnabled = true
    }
    
}
