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

class DetailedVC: UIViewController,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var bigImageView: UIImageView!
    
    var place: GMSPlace?
    
    var images:[UIImage?]=[]
    
    var placeId: String?
    private var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUpCollectionView()

        placesClient = GMSPlacesClient.shared()
        fetchImages()
        
        /*
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchImages()
            DispatchQueue.main.async {
                print("reloading")
                self.imageCollectionView.reloadData()
            }

        }
 */
    }
    
    func fetchImages() {
        let placeFields = GMSPlaceField(rawValue:
          GMSPlaceField.name.rawValue | GMSPlaceField.formattedAddress.rawValue
        )!
        
        //"ChIJH8JwWVlbCogRgDGgMO6tcmY"
        
        /* placesClient?.fetchPlace(fromPlaceID: "ChIJH8JwWVlbCogRgDGgMO6tcmY",
                                 placeFields: placeFields,
                                 sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          } */
          if let place = place {
            // Get the metadata for the first photo in the place photo metadata list.
            let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]

            // Call loadPlacePhoto to display the bitmap and attribution.
            for (index, imageMetadata) in place.photos!.enumerated() {
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
        //})
    }
    
    func setupTableView() {
        reviewsTableView.dataSource = self
        reviewsTableView.delegate = self
        reviewsTableView.register(UINib(nibName: PlaceReviewTableViewCell.NIB_NAME, bundle: nil), forCellReuseIdentifier: Constants.reviewCellId)
    }
    
    func setUpCollectionView(){
        imageCollectionView.dataSource=self
        imageCollectionView.delegate=self
        //imageCollectionView.register(DetailedVCImageCell.self, forCellWithReuseIdentifier: "imageCollection")
    }
}


extension DetailedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reviewCellId, for: indexPath)
        //cell.detailTextLabel
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
