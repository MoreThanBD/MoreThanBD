//
//  PlaceListViewController.swift
//  MoreThanBD
//
//  Created by Sai Akhil Pulikam on 7/20/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseFirestore

class PlaceListViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    var places: [Place] = []
    var currentLocation: CLLocation?
    let locationM=CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPlaces()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: PlaceTableViewCell.NIB_NAME, bundle: nil), forCellReuseIdentifier: Constants.placeCellId)
    }
    
    
    
    func fetchPlaces() {
        Firestore.firestore().collection("reviews").getDocuments {[weak self] (snapshot, error) in
            var places = [Place]()
            if let documents = snapshot?.documents {
                for document in documents {
                    let placeData = document.data()
                    let place = Place.placeFromDictionary(dict: placeData)
                    
                    places.append(place)
                }
                self?.places = places
                self?.tableView.reloadData()
            }
        }
    }
}

extension PlaceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.placeCellId, for: indexPath) as! PlaceTableViewCell
        let place = places[indexPath.row]
        
        //07-29
        //set the  distance variable before the cell's place  is set!!!
        let targatLocation=CLLocation(latitude: place.lat ?? 0, longitude: place.lng ?? 0)
        //cell.distance=currentLocation?.distance(from: targatLocation)
        cell.distance=(currentLocation?.distance(from: targatLocation) as! Double)/1609
        cell.place = place
        
        //07-29
        print(currentLocation ?? "Empty")
        print(cell.distance)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
}


extension PlaceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "DetailedVC") as! DetailedVC
        detailVC.placeId = place.placeId
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension PlaceListViewController {
    struct Constants {
        static let placeCellId = "placeCellId"
    }
}
