//
//  DetailedVC.swift
//  MoreThanBD
//
//  Created by 马晓雯 on 7/18/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseFirestore

class DetailedVC: UIViewController,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var bigImageView: UIImageView!
    
    var place: GMSPlace?
    var placeId: String?
    
    var reviews: [Review] = []
    
    var images:[UIImage?]=[]
    
    private var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUpCollectionView()

        placesClient = GMSPlacesClient.shared()
        fetchImages()
        fetchReviews()
    }
    @IBAction func addComment(_ sender: Any) {
        let addComment=storyboard?.instantiateViewController(identifier: "addCommentVC") as! AddCommentVC
        navigationController?.pushViewController(addComment, animated: true)
        }
    
    func fetchReviews() {
        guard let placeId = placeId else { return }
        Firestore.firestore().collection("reviews").document(placeId).getDocument {[weak self] (snapshot, error) in
            if error == nil {
                let placeObj = snapshot?.data() ?? [:]
                let place = Place.placeFromDictionary(dict: placeObj)
                self?.reviews = place.reviews ?? []
                self?.reviewsTableView.reloadData()
            }
        }
    }
    
    func fetchImages() {
        guard let placeId = placeId else { return }
       
        
        //"ChIJH8JwWVlbCogRgDGgMO6tcmY"
        
        placesClient?.fetchPlace(fromPlaceID: placeId,
                                 placeFields: .photos,
                                 sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }
          if let place = place {
            // Get the metadata for the first photo in the place photo metadata list.
            //let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]

            // Call loadPlacePhoto to display the bitmap and attribution.
            for (index, imageMetadata) in (place.photos ?? []).enumerated() {
                self.placesClient?.loadPlacePhoto(imageMetadata, callback: { (photo, error) -> Void in
                  if let error = error {
                    // TODO: Handle the error.
                    print("Error loading photo metadata: \(error.localizedDescription)")
                    return
                  } else {
                    // Display the first image and its attributions.
                    if index == 0 {
                        self.bigImageView?.image = photo;
                    } else {
                        self.images.append(photo)
                        self.imageCollectionView.reloadData()
                    }
                    //self.lblText?.attributedText = photoMetadata.attributions;
                  }
                })
                
            }
            
          }
        })
    }
    
    func setupTableView() {
        reviewsTableView.dataSource = self
        reviewsTableView.delegate = self
        reviewsTableView.register(UINib(nibName: PlaceReviewTableViewCell.NIB_NAME, bundle: nil), forCellReuseIdentifier: Constants.reviewCellId)
        reviewsTableView.tableFooterView = UIView()
    }
    
    func setUpCollectionView(){
        imageCollectionView.dataSource=self
        imageCollectionView.delegate=self
        //imageCollectionView.register(DetailedVCImageCell.self, forCellWithReuseIdentifier: "imageCollection")
    }
}


extension DetailedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reviewCellId, for: indexPath) as! PlaceReviewTableViewCell
        let review = reviews[indexPath.row]
        cell.review = review
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
}

extension DetailedVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}

extension DetailedVC {
    struct Constants {
        static let reviewCellId = "reviewCellId"
    }
}

extension DetailedVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
        //return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollection", for: indexPath) as! DetailedVCImageCell
        // let image=UIImage(named: "Image")
        let image = images[indexPath.item]
        cell.imageView.image=image
        //cell.backgroundColor = .blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            //return CGSize(width: 200, height: 200)
        return CGSize(width:80,height:100)
    }
    
}
