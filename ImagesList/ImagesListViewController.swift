import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    
    private var imageView = UIImageView()
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    private func loadPhotos() {
        print("START LOADING PHOTOS")
        print("ARRAY OF PHOTOS BEFORE LOADING NEW PAGE", imagesListService.photosFull.count)
        ImagesListService().fetchPhotosNextPage() { [weak self] result in
            switch result  {
            case .success:
                print("ARRAY COUNT AFTER", self?.imagesListService.photosFull.count as Any)
                let photosCount = try! result.get().count
                for photos in 0..<photosCount {
                    self?.imagesListService.photosFull.append(self?.imagesListService.convertPhotosStruct(response: try! result.get()[photos]) ?? [] as! Photo
                    )}
                //print("PHOTOS FULL ARRAY", self?.imagesListService.photosFull ?? "NO PHOTOS IN ARRAY")
                self?.tableView.reloadData()
                
            case .failure(let error):
                print("FAILED TO LOAD PHOTOS", error.localizedDescription)
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imagesListService.photosFull.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
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
        let image = imagesListService.photosFull[indexPath.row]
        let url = URL(string: String(image.thumbImageURL))
        cell.cellImage.kf.setImage(with: url)
        
        guard let date = image.createdAt as Date? else { return }
        cell.dateLabel.text = dateFormatter.string(from: date)
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}
