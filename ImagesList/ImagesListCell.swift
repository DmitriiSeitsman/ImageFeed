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
    }
    
    @IBAction func changeLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)

    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
