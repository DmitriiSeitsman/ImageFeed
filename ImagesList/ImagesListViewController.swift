import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    
    private var lastLoadedPage: Int = 1
    private var imageView = UIImageView()
    private var photosServiceObserver: NSObjectProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
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
            ) { [weak self] countOfArrayBefore in
                guard let self = self else { return }
                guard
                    let value = countOfArrayBefore.userInfo?.values.first,
                    let photosArray = value as? Int
                else {
                    print("Невозможно привести userInfo к Int")
                    return
                }
                print("OLD PHOTOS ARRAY COUNT:", photosArray)
                updateTableViewAnimated(oldArrayCount: photosArray)
            }
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
    
    deinit {
        if let observer = photosServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    private func resize ( _ tableView: UITableView, indexPath: IndexPath) -> CGSize {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imagesListService.photosFull[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imagesListService.photosFull[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return CGSize(width: imageViewWidth, height: cellHeight)
    }
    
    private func loadPhotos() {
        assert(Thread.isMainThread)
        print("START LOADING PHOTOS")
        print("ARRAY OF PHOTOS BEFORE LOADING NEW PAGE", imagesListService.photosFull.count)
        let countOfArrayBefore = imagesListService.photosFull.count
        imagesListService.fetchPhotosNextPage() { [weak self] result in
            switch result  {
            case .success (let photoResponses):
                for response in photoResponses {
                    let photo = self?.imagesListService.convertPhotosStruct(response: response)
                    if let photo = photo {
                        self?.imagesListService.photosFull.append(photo)
                    } else {
                        print("UNABLE TO CONVERT photoPackResponse to Photo")
                    }
                }
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photosFull": countOfArrayBefore])
                print("ARRAY COUNT AFTER", self?.imagesListService.photosFull.count as Any)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
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
    
    private func updateTableViewAnimated(oldArrayCount: Int) {
        if oldArrayCount == 0 {
            return
        }
        let oldCount = oldArrayCount
        let newCount = imagesListService.photosFull.count
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
    
    private  func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let image = imagesListService.photosFull[indexPath.row]
        let url = URL(string: String(image.thumbImageURL))
        
        let placeholderImage = UIImage(resource: .tableViewPlaceholder)
        cell.cellImage.contentMode = .center
        cell.cellImage.backgroundColor = .ypGray
        let size: CGSize = resize(tableView, indexPath: indexPath)
        let processor = ResizingImageProcessor(referenceSize: size)
        cell.cellImage.kf.setImage(with: url, placeholder: placeholderImage, options: [.processor(processor)]) {_ in
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        guard let date = image.createdAt as Date?
        else {
            cell.dateLabel.text = ""
            return
        }
        
        cell.dateLabel.text = dateFormatter.string(from: date)
        setLikeIcon(for: cell, indexPath: indexPath)
    }
    
    private func setLikeIcon(for cell: ImagesListCell, indexPath: IndexPath) {
        let image = imagesListService.photosFull[indexPath.row]
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
        
        let likeImage = UIImage(resource: like ? .likeButtonOff : .likeButtonOn)
        cell.likeButton.setImage(likeImage, for: .normal)
        
        ProgressHUD.animate()
        cell.likeButton.isUserInteractionEnabled = false
        cell.isUserInteractionEnabled = false
        
        imagesListService.changeLike(photoId: photo.id, isLike: like) { [weak self] response in
            switch response {
            case .success:
                print("LIKE CHANGED")
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                    cell.likeButton.isUserInteractionEnabled = true
                    cell.isUserInteractionEnabled = true
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.setLikeIcon(for: cell, indexPath: indexPath)
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось изменить лайк", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }
                print("LIKE WAS NOT CHANGED, REASON:", error)
                ProgressHUD.dismiss()
                cell.likeButton.isUserInteractionEnabled = true
                cell.isUserInteractionEnabled = true
            }
        }
        imagesListService.task = nil
    }
    
}
