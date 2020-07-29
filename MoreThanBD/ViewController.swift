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
import FirebaseAuth
import FirebaseFirestore

struct Restaurant{
    var name:String?
    var latitude:Double?
    var longitude:Double?
    var id:Int?
    var marker:GMSMarker?
}

class ViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    let locationManager = CLLocationManager()
    
    //an array of restaurants that will be pinned on the map
    var places: [Restaurant]=[]
    
    //07-29  loadMarkers
    var marker_places=[Place]()//this array stores all the restaurants  added by our  users
    var markers=[GMSMarker]()//this array stores all the markers of restaurants as GMSMarker
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager  = CLLocationManager()
        setupLocation()
        
        //conform to GMSMapViewDelegate for tapping on a marker
        mapView.delegate=self
        
            //07-29 loadMarkers
        //this function will add pins to the map
        loadRestaurants()
        
        /*
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadRestaurants()//this function will load the restaurant's informationinto var places
            DispatchQueue.main.async {
                self.loadPins()
            }
        }
 */

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //locationManager.requestAlwaysAuthorization()
        
    }

    func setupLocation() {
        print("setting up location")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        //locationManager?.requestLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.startUpdatingLocation()
        guard let coordinate = locationManager.location?.coordinate else {
            return
        }
        
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            print("Permitted... ", locationManager.location?.coordinate.latitude)
            print("Permitted... ", locationManager.location?.coordinate.longitude)
        }
        
        print(coordinate)
        //zoomToLocation(coordinate: coordinate)
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed...", error.localizedDescription)
    }
    
    func zoomToLocation(coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
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
       /* GoogleApi.shared.callApi(.nearBy, input: input) { (response) in
            if let data = response.data as? [GApiResponse.NearBy], response.isValidFor(.nearBy){
                for place in data {
                    //print("Place...: ", place.formattedAddress)
                }
            }
        }
         */
    }
    @IBAction func addLocation(_ sender: Any) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    func loadRestaurants(){
        self.mapView.clear()//clear up the mapView
        Firestore.firestore().collection("reviews").getDocuments {[weak self] (snapshot, error) in
            var places = [Place]()
            var loadedMarkers=[GMSMarker]()
            if let documents = snapshot?.documents {
                for document in documents {
                    let placeData = document.data()
                    let place = Place.placeFromDictionary(dict: placeData)
                    
                    places.append(place)
                    print("A place lat \(String(describing: place.lat))")
                    
                    let cord2D=CLLocationCoordinate2D(latitude: place.lat!, longitude: place.lng!)
                    print("adding marker")
                    let marker = GMSMarker()
                    marker.position =  cord2D
                    marker.title = "Location"
                    marker.snippet = place.name
                    
                    let markerImage = UIImage(systemName: "star.fill")!
                    let markerView = UIImageView(image: markerImage)
                    marker.iconView=markerView
                    marker.map=self?.mapView
                    
                    loadedMarkers.append(marker)
                }
                self?.marker_places = places
                self?.markers=loadedMarkers
            }
        }
        for p in self.marker_places{
            print(p.name!)
        }
        print("count is\(self.marker_places.count)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PlaceListViewController {
            destination.currentLocation = locationManager.location
            print("!!!!!!!!!!!!")
            print(destination.currentLocation ?? "nothing")
        }
    }
    
    @IBAction func logoutUser(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            
            let startNavController=storyboard?.instantiateViewController(identifier: "startNavController") as! UINavigationController
            
            view.window?.rootViewController = startNavController
            view.window?.makeKeyAndVisible()
        }
        catch let error{
            print("Logout failed", error)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Place.currentLocation = locations.first
        print(locations[0])
        if let loc = locations.first {
            zoomToLocation(coordinate: loc.coordinate)
        }
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
            //Place.currentLocation = locationManager?.location
            print("Got here...", location.coordinate.latitude)
            print("Got here...", location.coordinate.longitude)
            zoomToLocation(coordinate: location.coordinate)
        @unknown default:
            print("Default...")
        }
    }
}

extension ViewController:GMSAutocompleteViewControllerDelegate,GMSMapViewDelegate{
    
    //this function will pop up the entire window, should we make the current collectionView on  this page the top rated ones?
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            
            print("Place name: \(String(describing: place.name))")
            dismiss(animated: true, completion: nil)
            
            //self.mapView.clear()
            
        let cord2D = CLLocationCoordinate2D(latitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude))
        print(place.coordinate.latitude)
        print(place.coordinate.longitude)
        
        /*
        //append the new place to the places array
        var newRest = Restaurant(name:place.name,latitude: place.coordinate.latitude,longitude: place.coordinate.longitude,id:3)
        let newMarker = GMSMarker()
                   newMarker.position = cord2D
                   newMarker.title = "Location"
                   newMarker.snippet = place.name
                   
                   let markerImage = UIImage(systemName: "star.fill")!
                   let markerView = UIImageView(image: markerImage)
                   newMarker.iconView=markerView
        newRest.marker=newMarker
        places.append(newRest)
        
        //call loadPins to reload pins
        loadPins()
 */
        //07-29 existing or new
        //check if the restaurant is already in the database
        var index=0
        var exist=false
        for p in marker_places{
            if (p.lat==place.coordinate.latitude&&p.lng==place.coordinate.longitude){
                // this place is already added, go to detailed vc instead of newloc  vc
                let restaurant = marker_places[index]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let detailVC = storyboard.instantiateViewController(identifier: "DetailedVC") as! DetailedVC
                detailVC.placeId = restaurant.placeId
                self.navigationController?.pushViewController(detailVC, animated: true)
                exist=true
            }
            index+=1
        }
        
        //this place is a new one, go to newloc vc
        //load the NewLocVC
        if(!exist){
        let NVC =  storyboard?.instantiateViewController(withIdentifier: "NewPlaceVC") as! NewLocVC
        NVC.name=place.name
        NVC.place = place
        navigationController?.pushViewController(NVC, animated: true)
        }
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let detailVC = storyboard.instantiateViewController(identifier: "DetailedVC") as! DetailedVC
//        detailVC.place = place
//        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
        dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func loadPins(){
        /*
        self.mapView.clear()//first clear the mapView
        
        for place in places{
            
            let cord2D = CLLocationCoordinate2D(latitude: (place.latitude!), longitude: (place.longitude!))
            let marker = GMSMarker()
            marker.position =  cord2D
            marker.title = "Location"
            marker.snippet = place.name
            
            let markerImage = UIImage(systemName: "star.fill")!
            let markerView = UIImageView(image: markerImage)
            marker.iconView=markerView
            marker.map=self.mapView
        }
        
        /**************/
        //will change this line to make the cameraPosition at the user's current location
        let location = CLLocationCoordinate2D(latitude: (places[0].latitude!), longitude: (places[0].longitude!))
        self.mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom: 15)
 */
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "DetailedVC") as! DetailedVC
        var index=0;
        for m in markers{
            if(m.position.latitude==marker.position.latitude&&m.position.longitude==marker.position.longitude){
                print(index)
                detailVC.placeId=marker_places[index].placeId
            }
            index+=1;
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
        
        return true;
    }
    
    
    
}


