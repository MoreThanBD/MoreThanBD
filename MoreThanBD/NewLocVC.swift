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

class NewLocVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadImageBtn: UIButton!
    var parentScene:UIViewController?
    var name:String?
    var uploadedImages:[UIImage]=[]
    var selectedAssets=[PHAsset]()
    var comment:String?

    @IBOutlet weak var textView: UITextView!//recommendation
    @IBOutlet weak var placeName: UITextField!
    
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
        placeName.text=name
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)
        imageView1.image=image
        uploadedImages.append(image)
    }
    
    func pushData(){
        //push data to firebase(including images, comments, ratings and relative fields)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
