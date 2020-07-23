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

class NewLocVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var starsCosmosView: CosmosView!
    @IBOutlet weak var uploadImageBtn: UIButton!
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
    
    @IBAction func addNewPlace(_ sender: Any) {
        if textView.text != ""{
            comment=textView.text
            //push data to firebase
            pushData()
            
            //go back to parent
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func choosePicture(_ sender: Any) {
        
        let vc = BSImagePickerViewController()
        vc.settings.maxNumberOfSelections=2//choose no more than 2 photos

        bs_presentImagePickerController(vc, animated: true,
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //placeName.text=name
        locationTitleLabel.text = place?.name
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)
        imageView1.image=image
        uploadedImages.append(image)
    }
    
    func pushData(){
        if let placeID = place?.placeID {
            for (index, image) in uploadedImages.enumerated() {
                let storageRef = Storage.storage().reference().child("places").child(placeID).child("image-\(index)")
                if let imageData = image.jpegData(compressionQuality: 0.75) {
                    storageRef.putData(imageData, metadata: nil) {[weak self] (meta, error) in
                        if error == nil {
                            storageRef.downloadURL { (url, error) in
                                if let urlString = url?.absoluteString {
                                    self?.uploadedImagesUrl.append(urlString)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func uploadData() {
        guard let userId = Auth.auth().currentUser?.uid, let placeId = place?.placeID else { return }
        let placeData: [String: Any] = [
            "name": place?.name ?? "",
            "stars": starsCosmosView.rating,
            "review": textView.text ?? ""
        ]
        
        let placesRef = Firestore.firestore().collection("reviews").document(placeId).collection("userreview").addDocument(data: placeData) { (error) in
            if error == nil {
                print("UPloaded Review...")
            }
        }
        
    }
}
