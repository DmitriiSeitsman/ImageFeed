import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    var image: UIImage?
    var url: URL?

    private var initialZoomScale: CGFloat = 1.0
    private let doubleTapZoomScale: CGFloat = 1.5

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.clipsToBounds = true
        scrollView.delegate = self
        setupGesture()
        setupScrollView()
        setPlaceholderImage()
        loadImage()
        scrollView.sendSubviewToBack(imageView)
    }

    private func setupGesture() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }

    private func setupScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = doubleTapZoomScale
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
    }

    private func loadImage() {
        guard let url else { return }
        
        ProgressHUD.animate()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                print("Loaded image from \(value.source.url!)")
                self.imageView.subviews.last?.removeFromSuperview()
                ProgressHUD.dismiss()
                
                if let image = self.imageView.image {
                    self.image = value.image
                    self.rescaleAndCenterImageInScrollView(image: image)
                }
            case .failure(let error):
                print("Image load failed: \(error.localizedDescription)")
                self.showErrorAlert()
            }
        }
    }

    private func showErrorAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Не удалось загрузить изображение", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setPlaceholderImage() {
        let placeholderImage = UIImage(named: "table_view_placeholder")
        let placeholderView = UIImageView(image: placeholderImage)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
    }

    @objc private func handleDoubleTap() {
        let currentZoom = scrollView.zoomScale
        let targetZoom = abs(currentZoom - initialZoomScale) < 0.01 ? doubleTapZoomScale : initialZoomScale
        let center = view.convert(view.center, to: imageView)
        
        let zoomRect = zoomRectForScale(scale: targetZoom, center: center)
        scrollView.zoom(to: zoomRect, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.centerImageIfNeeded()
        }
    }

    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let scrollViewSize = scrollView.bounds.size
        
        zoomRect.size.width = scrollViewSize.width / scale
        zoomRect.size.height = scrollViewSize.height / scale
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0

        return zoomRect
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        scrollView.layoutIfNeeded()

        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size

        guard imageSize.width > 0, imageSize.height > 0 else { return }

        let hScale = scrollViewSize.width / imageSize.width
        let vScale = scrollViewSize.height / imageSize.height
        let minScale = min(hScale, vScale)

        initialZoomScale = minScale
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale

        let imageViewWidth = imageSize.width * minScale
        let imageViewHeight = imageSize.height * minScale
        imageView.frame = CGRect(x: 0, y: 0, width: imageViewWidth, height: imageViewHeight)

        scrollView.contentSize = imageView.frame.size

        let horizontalInset = max((scrollViewSize.width - imageViewWidth) / 2, 0)
        let verticalInset = max((scrollViewSize.height - imageViewHeight) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: verticalInset,
                                               left: horizontalInset,
                                               bottom: verticalInset,
                                               right: horizontalInset)
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let url else {
            print("No URL to share.")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }

}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageIfNeeded()
    }

    private func centerImageIfNeeded() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size

        let horizontalInset = max((scrollViewSize.width - imageViewSize.width) / 2, 0)
        let verticalInset = max((scrollViewSize.height - imageViewSize.height) / 2, 0)

        scrollView.contentInset = UIEdgeInsets(top: verticalInset,
                                               left: horizontalInset,
                                               bottom: verticalInset,
                                               right: horizontalInset)
    }

}
