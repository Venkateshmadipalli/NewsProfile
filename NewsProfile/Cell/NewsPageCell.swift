//
//  NewsPageCell.swift
//  NewsProfile
//
//  Created by Apple on 16/05/25.
//

//import UIKit
//
//class NewsPageCell: UICollectionViewCell {
//    @IBOutlet weak var contentLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var authorLabel: UILabel!
//    @IBOutlet weak var titleLabel: UILabel!
//    var onSwipeRight: (() -> Void)?
//    var onSwipeLeft: (() -> Void)?
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        contentLabel.numberOfLines = 0
//        descriptionLabel.numberOfLines = 0
//        authorLabel.numberOfLines = 0
//        titleLabel.numberOfLines = 0
//        setupGestures()
//    }
//    func configure(with article: Article) {
//        titleLabel.text = nil
//            descriptionLabel.text = nil
//            authorLabel.text = nil
//            contentLabel.text = nil
//            imageView.image = nil
//        titleLabel.text = article.title
//        descriptionLabel.text = article.description
//        authorLabel.text = article.author != nil ? "Author By \(article.author!)" : "Author Unknown"
//        contentLabel.text = article.content
//
//        if let urlStr = article.urlToImage, let url = URL(string: urlStr) {
//            loadImage(from: url)
//        } else {
//            imageView.image = nil
//        }
//    }
//
//    private func loadImage(from url: URL) {
//        let currentURL = url.absoluteString
//        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
//            guard let self = self, let data = data else { return }
//            DispatchQueue.main.async {
//                // Optional: check if imageView is still valid for this URL
//                self.imageView.image = UIImage(data: data)
//            }
//        }.resume()
//    }
//    func setupGestures() {
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
//        swipeRight.direction = .right
//        contentView.addGestureRecognizer(swipeRight)
//        
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
//        swipeLeft.direction = .left
//        contentView.addGestureRecognizer(swipeLeft)
//    }
//    
//    @objc func handleSwipeRight() {
//        onSwipeRight?()
//    }
//    
//    @objc func handleSwipeLeft() {
//        onSwipeLeft?()
//    }
//}
import UIKit

class NewsPageCell: UICollectionViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    var onSwipeRight: (() -> Void)?
    var onSwipeLeft: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        authorLabel.numberOfLines = 0
        titleLabel.numberOfLines = 0
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        setupGestures()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        descriptionLabel.text = nil
        authorLabel.text = nil
        contentLabel.text = nil
        imageView.image = nil
    }
    func configure1(with article: Article, fallbackImage: UIImage?) {
        prepareForReuse()
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        authorLabel.text = article.author

        // Prefer remote image if available
        if let imageUrlString = article.urlToImage,
           let url = URL(string: imageUrlString) {
            imageView.loadImage(from: url) // Your custom async loader
        } else if let image = fallbackImage {
            imageView.image = image
        } else {
            imageView.image = UIImage(named: "placeholder") // Optional
        }
    }
    func configure(with article: Article) {
        // Reset
         prepareForReuse()

        titleLabel.text = article.title
        descriptionLabel.text = article.description
        authorLabel.text = article.author != nil ? "Author By \(article.author!)" : "Author Unknown"
        contentLabel.text = article.content

        
        if let urlStr = article.urlToImage, let url = URL(string: urlStr) {
            loadImage(from: url)
        } else {
            if let imageData = Data(base64Encoded: article.url ?? ""),
               let image = UIImage(data: imageData) {
                imageView.image = resizeImage(image: image, targetSize: CGSize(width: 100, height: 100))
                imageView.contentMode = .scaleAspectFill // Adjusts the image to fit within the bounds while maintaining aspect ratio

            }else{
                imageView.image = nil
           }
            }

        // Ensure layout is refreshed
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Determine the scale factor
        let scaleFactor = min(widthRatio, heightRatio)

        // Calculate new size
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        // Resize the image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }

    private func setupGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        contentView.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        contentView.addGestureRecognizer(swipeLeft)
    }

    @objc private func handleSwipeRight() {
        onSwipeRight?()
    }

    @objc private func handleSwipeLeft() {
        onSwipeLeft?()
    }
}
extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        self.image = placeholder

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                error == nil,
                let image = UIImage(data: data)
            else {
                print("Failed to load image from url: \(url), error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
