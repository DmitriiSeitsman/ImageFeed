import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let imageView = cellImage else { return }
        imageView.kf.cancelDownloadTask()
        likeButton.accessibilityIdentifier = nil
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        likeButton.setImage(image, for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? "like button on" : "like button off"
    }
    
    @IBAction func changeLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }

}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
