//
//  PlaceReviewTableViewCell.swift
//  MoreThanBD
//
//  Created by Sai Akhil Pulikam on 7/20/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit
import Cosmos
import FirebaseStorage

class PlaceReviewTableViewCell: UITableViewCell {
    let storage = Storage.storage()
    
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewerIcon: UILabel!
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
    
    func setReviewInformation() {
        guard let thisReview = review else{
            print("No review")
            return
        }
        
        reviewerName.text = thisReview.reviewerName
        reviewerIcon.text = String(thisReview.reviewerName.prefix(1))
        starsCosmosView.rating = Double(thisReview.stars)
        reviewLabel.text = thisReview.review
        
        //laod images off main thread to load the cell faster
        if thisReview.images.count > 0{
            let httpsReference = self.storage.reference(forURL: thisReview.images[0])
            
            httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error{
                    print("Error with loading in iamge", error)
                }
                else{
                    self.placeImageOneView.image = UIImage(data: data!)
                }
            }
        }
        
        if thisReview.images.count > 1{
            let httpsReference = self.storage.reference(forURL: thisReview.images[1])
            
            httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error{
                    print("Error with loading in iamge", error)
                }
                else{
                    self.placeImageTwoView.image = UIImage(data: data!)
                }
            }
        }
            
        if thisReview.images.count > 2{
            let httpsReference = self.storage.reference(forURL: thisReview.images[2])
            
            httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error{
                    print("Error with loading in iamge", error)
                }
                else{
                    self.placeImageThreeView.image = UIImage(data: data!)
                }
            }
        }
        
        if thisReview.images.count > 3{
            let httpsReference = self.storage.reference(forURL: thisReview.images[3])
            
            httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error{
                    print("Error with loading in iamge", error)
                }
                else{
                    self.placeImageFourView.image = UIImage(data: data!)
                }
            }
        }
    }
    
}
