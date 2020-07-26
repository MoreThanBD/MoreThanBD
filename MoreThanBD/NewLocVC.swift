//
//  NewLocVC.swift
//  MoreThanBD
//
//  Created by 马晓雯 on 7/18/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import GooglePlaces
import Cosmos

class NewLocVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate {
    
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var starsCosmosView: CosmosView!
    @IBOutlet weak var uploadImageBtn: UIButton!
    
    @IBOutlet weak var theTextView: UITextView!
    @IBOutlet weak var addPlaceBtn: UIButton!
    
    var parentScene:UIViewController?
    var name:String?
    var uploadedImages:[UIImage]=[]
    var uploadedImagesUrl: [String] = []
    var selectedAssets=[PHAsset]()
    var comment:String?
    var place: GMSPlace?

    @IBOutlet weak var textView: UITextView!//recommendation
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBAction func addNewPlace(_ sender: Any) {
        if textView.text != ""{
            comment=textView.text
            //push data to firebase
            pushData()
        }
    }
    
    func goBack() {
        //go back to parent
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func choosePicture(_ sender: Any) {
        
        let vc = ImagePickerController()
        vc.settings.selection.max=4//choose no more than 4 photos

        presentImagePicker(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
              // User selected an asset.
              // Do something with it, start upload perhaps?
            }, deselect: { (asset: PHAsset) -> Void in
              // User deselected an assets.
              // Do something, cancel upload?
            }, cancel: { (assets: [PHAsset]) -> Void in
              // User cancelled. And this where the assets currently selected.
            }, finish: { (assets: [PHAsset]) -> Void in
              // User finished with these assets
                for i in 0..<assets.count
                {
                    self.selectedAssets.append(assets[i])
                    print(self.selectedAssets)
                }
                self.getAllImages()
        }, completion: nil)
        
        
        /*
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
 */
 
    }
    
    func getAllImages() -> Void {

        print("get all images method called here")
        if selectedAssets.count != 0{
            for i in 0..<selectedAssets.count{
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: selectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                })
                self.uploadedImages.append(thumbnail)
            }
            imageView1.image=uploadedImages[0]
            if uploadedImages.count>1{
                imageView2.image=uploadedImages[1]
            }
            if uploadedImages.count>2{
                imageView3.image=uploadedImages[2]
            }
            if uploadedImages.count==4{
                imageView4.image=uploadedImages[3]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //placeName.text=name
        textView.delegate=self

        locationTitleLabel.text = place?.name
        setStyle()
    }
    func setStyle(){
        textView.text = "Click here to add some comment"
        textView.textColor = UIColor.lightGray
        
        addPlaceBtn.layer.cornerRadius=15;
        addPlaceBtn.layer.backgroundColor=UIColor.systemGray6.cgColor
        
        uploadImageBtn.layer.cornerRadius=15;
        uploadImageBtn.layer.backgroundColor=UIColor.systemGray6.cgColor
        
        theTextView.layer.cornerRadius=20
        theTextView.layer.backgroundColor=UIColor.systemGray6.cgColor
        
        imageView1.layer.borderWidth=2
        imageView1.layer.cornerRadius=15
        imageView1.layer.borderColor=UIColor.systemGray6.cgColor
        imageView2.layer.borderWidth=2
        imageView2.layer.cornerRadius=15
        imageView2.layer.borderColor=UIColor.systemGray6.cgColor
        imageView3.layer.borderWidth=2
        imageView3.layer.cornerRadius=15
        imageView3.layer.borderColor=UIColor.systemGray6.cgColor
        imageView4.layer.borderWidth=2
        imageView4.layer.cornerRadius=15
        imageView4.layer.borderColor=UIColor.systemGray6.cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)
        //imageView1.image=image
        //uploadedImages.append(image)
    }
    
    func pushData(){
        if let placeID = place?.placeID {
            if uploadedImages.count == 0 {
                self.uploadData { (completed) in
                    if(completed) {
                        self.goBack()
                    }
                }
            } else {
                for (index, image) in uploadedImages.enumerated() {
                    let storageRef = Storage.storage().reference().child("places").child(placeID).child("image-\(index)")
                    if let imageData = image.jpegData(compressionQuality: 0.75) {
                        storageRef.putData(imageData, metadata: nil) {[weak self] (meta, error) in
                            if error == nil {
                                storageRef.downloadURL { (url, error) in
                                    if let urlString = url?.absoluteString {
                                        self?.uploadedImagesUrl.append(urlString)
                                    }
                                    if index == (self?.uploadedImages.count ?? 0) - 1 {
                                        self?.uploadData { (completed) in
                                            if(completed) {
                                                self?.goBack()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func uploadData(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid, let place = self.place, let placeId = place.placeID else { return }
        
        let reviewData: [String: Any] = [
            "name": place.name ?? "",
            "stars": starsCosmosView.rating,
            "review": textView.text ?? "",
            "reviewerName": AppData.userName ?? "",
            "reviewerId": userId,
            "images": self.uploadedImagesUrl
        ]
        
        var placeData: [String: Any] = [
            "name": place.name ?? "",
            "lng": place.coordinate.longitude,
            "lat": place.coordinate.latitude,
            "placeId": placeId,
            "placeImage": uploadedImagesUrl.first ?? ""
        ]
        
        placeData["userreviews"] = FieldValue.arrayUnion([reviewData])
        Firestore.firestore().collection("reviews").document(placeId).setData(placeData, merge: true) { (error) in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        
        /*
        
        Firestore.firestore().collection("reviews").document(placeId).updateData(["userreviews" : FieldValue.arrayUnion([reviewData])]) { (error) in
            if error == nil {
                print("UPloaded Review...")
                Firestore.firestore().collection("reviews").document(placeId).setData(placeData)
                completion(true)
            } else if error!.localizedDescription.contains("No document to update") {
                placeData["userreviews"] = FieldValue.arrayUnion([reviewData])
                Firestore.firestore().collection("reviews").document(placeId).setData(placeData) { (error) in
                    if error == nil {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
 
 */
       /*
        Firestore.firestore().collection("reviews").document(placeId).collection("userreviews").document(userId).setData(reviewData) { (error) in
            if error == nil {
                print("UPloaded Review...")
                Firestore.firestore().collection("reviews").document(placeId).setData(placeData)
                completion(true)
            } else {
                completion(false)
            }
        }*/
    }
}

