//
//  ViewController.swift
//  SeaFood
//
//  Created by ad lay on 8/16/19.
//  Copyright © 2019 ad lay. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let API_KEY = "uvmGknloiliToxv6EGUDA_WOpUDm9PDvpM881-8KKs6b"
    let VERSION = "2019-08-31"
    let URL = "https://gateway.watsonplatform.net/visual-recognition/api"
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topBarImageView: UIImageView!
    var classfiedImage : UIImage?
    let imagePicker = UIImagePickerController()
    var classficationResults : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isHidden = true;
        imagePicker.delegate = self
    }

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        let localThreshold: Double = 0.0
        let classifierId = "default"
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            guard let resizedImage = image.resized(withPercentage: 0.1) else {
                print("could not resize image")
                return
            }
            classfiedImage = resizedImage
            
            
            let visualRecognition = VisualRecognition(version: VisualRecognitionConstants.version, apiKey: API_KEY)
            visualRecognition.classify(image: resizedImage, threshold: localThreshold, classifierIDs: [classifierId]) { response, error in
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                    // Make sure that an image was successfully classified.
                    guard let classifications = response?.result?.images.first?.classifiers.first?.classes else {
                        return
                    }
                    print("^^^ these are the classifcations \(classifications)")
                    self.classficationResults = []
                    for index in  0..<classifications.count{
                        self.classficationResults.append(classifications[index].className)
                    }
                    if(self.classficationResults.contains("hotdog")){
                        self.setupNav(title: "Hotdog!", isHotdog: true)
                    }
                    else {
                        self.setupNav(title: self.classficationResults[0], isHotdog: false)
                    }
                    print("**** \(self.classficationResults)")
                
                }
            }

        } else {
            print("there was an error picking the image")
        }
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        print("shareTapped")
        if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)){
            if let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter ){
                vc.setInitialText("My food is \(self.navigationItem.title!)")
                vc.add(self.classfiedImage)
                present(vc, animated: true, completion: nil)
            }
        }
        else {
            let alertController = UIAlertController(title: "Twitter avaialble.", message: "We are unable to find a twitter account on this device", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: false)
        }
    }
    func setupNav(title :String, isHotdog:Bool){
        DispatchQueue.main.async {
            self.topBarImageView.image = UIImage(named: isHotdog ? "hotdog" : "not-hotdog" )
            let color = isHotdog ? UIColor.green : UIColor.red
            self.navigationController?.navigationBar.barTintColor = color
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationItem.title = title
        }
    }
    
}


