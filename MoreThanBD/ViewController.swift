//
//  ViewController.swift
//  MoreThanBD
//
//  Created by 马晓雯 on 7/18/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager: CLLocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager  = CLLocationManager()
        setupLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager?.requestAlwaysAuthorization()
    }

    func setupLocation() {
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        guard let coordinate = locationManager?.location?.coordinate else {
            return
        }
        
        zoomToLocation(coordinate: coordinate)
        
    }
    
    func zoomToLocation(coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 11)
        //mapView.camera = camera
        mapView.animate(to: camera)
        fetchRestaurants(around: coordinate)
    }
    
    func fetchRestaurants(around location: CLLocationCoordinate2D) {
        var input = GInput()
        input.keyword = "Restaurant"
        input.radius = 1500
        var gLocation = GLocation()
        gLocation.latitude = location.latitude
        gLocation.longitude = location.longitude
        
        input.destinationCoordinate = gLocation
        GoogleApi.shared.callApi(.nearBy, input: input) { (response) in
            if let data = response.data as? [GApiResponse.NearBy], response.isValidFor(.nearBy){
                for place in data {
                    print("Place...: ", place.formattedAddress)
                }
            }
        }
    }

}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updating... ", locations.first)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        case .notDetermined:
            print("Not Determined... ")
        case .restricted:
            print("Restricted... ")
        case .denied:
            print("Location Access Denied")
        case .authorizedAlways, .authorizedWhenInUse:
            guard let location = manager.location else { return }
            zoomToLocation(coordinate: location.coordinate)
        @unknown default:
            print("Default...")
        }
    }
}
