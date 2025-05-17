//
//  ArticleCell.swift
//  NewsProfile
//
//  Created by Apple on 16/05/25.
//

import UIKit

class ArticleCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    private var currentImageURL: String?

       override func prepareForReuse() {
           super.prepareForReuse()
           imageView.image = nil
           currentImageURL = nil
       }
   
    func configure(with article: Article) {
        titleLabel.text = article.title
        imageView.image = nil  // Clear previous image
        guard let imageUrl = article.urlToImage, let url = URL(string: imageUrl) else {
            return
        }
        currentImageURL = imageUrl
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }

            // Prevent mismatched image
            if self.currentImageURL == imageUrl {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}

