//
//  NewBusinessViewController.swift
//  BlockIslandTodayGit
//
//  Created by Roman Dzhugan on 4/4/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class NewBusinessViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var businessDescr: UITextField!
    @IBOutlet weak var businessName: UITextField!
    @IBOutlet weak var businessLogo: UIImageView!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    var categories = ["Restaurant", "Taxi", "Hotel", "Shop"]
    var imageArray = [UIImage]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func newImageTapped(_ sender: UITapGestureRecognizer) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            
            present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        businessLogo.image = selectedPhoto
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        if (businessName.text?.characters.count)!>0 {
            let refData = FIRDatabase.database().reference(fromURL: "https://blockislandtoday-302d7.firebaseio.com/")
            let name = businessName.text
            let businessReference = refData.child("Businesses").child("\(name!)")
            let imageName = UUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("Business Logos").child("\(imageName).jpg")
            if let uploadData = UIImageJPEGRepresentation(businessLogo.image!, 0.2) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print (error as Any)
                        return
                    } else if let postImageURL = metadata?.downloadURL()?.absoluteString {
                        let value = ["businessName": self.businessName.text ?? "", "businessLogo": postImageURL, "businessDescription": self.businessDescr.text ?? "", "category": self.categoryField.text ?? "", "phone": self.phoneNumber.text ?? "", "email": ""] as [String : Any]
                            businessReference.updateChildValues(value, withCompletionBlock: { (err, ref) in
                                if err != nil {
                                    print(err as Any)
                                    return
                                }
                                
                                self.createAlert(title: "New Business", message: "New business has been created")
                                
                            })
                    }
                        
                })
            }
            
        } else {
            createAlert(title: "Registering", message: "Please insert some more data")
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryField.text = categories[row]
        categoryPicker.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == categoryField) {
            categoryPicker.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for i in 0..<imageArray.count{
//            let imageView = UIImageView()
//            imageView.image = imageArray[i]
//            let xPosition = imageScrollView.frame.width * CGFloat(i)
//            imageView.frame = CGRect(x: xPosition, y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height)
//            
//            imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(i + 1)
//            imageScrollView.addSubview(imageView)
//        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
    }))
        self.present(alert, animated: true, completion: nil)
    }

}
