//
//  PlaceTableViewCell.swift
//  MoreThanBD
//
//  Created by Sai Akhil Pulikam on 7/20/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage

class PlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var averageRatingLabel: UILabel!
    
    static let NIB_NAME = "PlaceTableViewCell"
    
    var place: Place? {
        didSet {
            guard let place = self.place else { return }
            nameLabel.text = place.name
            ratingView.rating = Double(place.averageRating ?? 0)
            distanceLabel.text = "\(place.distanceAway ?? 0)"
            averageRatingLabel.text = String(format: "%0.1f", place.averageRating ?? 0)
            if let imageUrlString = place.placeImageString, let url = URL(string: imageUrlString) {
                placeImageView.sd_setImage(with: url, placeholderImage: nil)
            }
            //placeImageView.image = place.placeImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
