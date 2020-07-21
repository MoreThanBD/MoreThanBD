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
    var images:[UIImage]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUpCollectionView()
        
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
    
    func fetchImages(){
        //this function will be written to fetch images from api?
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
        //return images.count
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollection", for: indexPath) as! DetailedVCImageCell
        let image=UIImage(named: "Image")
        //cell.imageView.image=image
        cell.backgroundColor = .blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            //return CGSize(width: 200, height: 200)
        return CGSize(width:80,height:100)
    }
    
}
