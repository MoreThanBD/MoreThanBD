//
//  PlaceReviewTableViewCell.swift
//  MoreThanBD
//
//  Created by Sai Akhil Pulikam on 7/20/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit
import Cosmos

class PlaceReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var starsCosmosView: CosmosView!
    @IBOutlet weak var reviewLabel: UITextView!
    @IBOutlet weak var placeImageOneView: UIImageView!
    @IBOutlet weak var placeImageTwoView: UIImageView!
    @IBOutlet weak var placeImageThreeView: UIImageView!
    @IBOutlet weak var placeImageFourView: UIImageView!
    
    var review:Review? {
        didSet {
            guard let review = self.review else { return }
            starsCosmosView.rating = Double(review.stars)
            reviewerName.text = review.reviewerName
            reviewLabel.text = review.review
            let imageViews = [placeImageOneView, placeImageTwoView, placeImageThreeView, placeImageFourView]
            
            for (index, imageUrlString) in review.images.enumerated() {
                if index >= imageViews.count { break }
                if let url = URL(string: imageUrlString) {
                    imageViews[index]?.sd_setImage(with: url, placeholderImage: nil)
                }
            }
        }
    }
    static let NIB_NAME = "PlaceReviewTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
