//
//  NewBusinessViewController.swift
//  BlockIslandTodayGit
//
//  Created by Roman Dzhugan on 4/4/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorage

class NewBusinessViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var businessDescr: UITextField!
    @IBOutlet weak var businessName: UITextField!
    @IBOutlet weak var businessLogo: UIImageView!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var latituteLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
//    @IBOutlet weak var map: MKMapView! {
//        didSet {
//            map.delegate = self
//            map.mapType = .hybrid
//        }
//    }
    
    let map = MKMapView()
    
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
                        let value = ["businessName": self.businessName.text ?? "", "businessLogo": postImageURL, "businessDescription": self.businessDescr.text ?? "", "category": self.categoryField.text ?? "", "phone": self.phoneNumber.text ?? "", "latitute": self.latituteLabel.text ?? "", "longitude": self.longitudeLabel.text ?? "", "email": ""] as [String : Any]
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
        
        map.delegate = self
        map.mapType = .hybrid
        map.frame = CGRect(x: 0, y: 5, width: 375, height: 253)
        super.viewDidLoad()
        view.addSubview(map)
        
        let location = CLLocationCoordinate2DMake(41.172959, -71.558155)
        map.setRegion(MKCoordinateRegionMakeWithDistance(location, 1500, 1500), animated: true)
        let annotation = Annotation(title: "Welcome to Block Island", subtitle: "You are here", coordinate: location)
        map.addAnnotation(annotation)
        
        let longTapGestureOnMap = UILongPressGestureRecognizer(target: self, action: #selector(lonTapGestureOnMap))
        map.addGestureRecognizer(longTapGestureOnMap)
    }
    
    func lonTapGestureOnMap(gestureRecognizer: UILongPressGestureRecognizer) {
        let touchLocation = gestureRecognizer.location(in: map)
        let locationCoordinate = map.convert(touchLocation, toCoordinateFrom: map)
        
        let annotation = Annotation(title: businessName.text!, subtitle: businessDescr.text!, coordinate: locationCoordinate)
        
        map.removeAnnotations(map.annotations)
        map.addAnnotation(annotation)
        
        let coord = map.convert(touchLocation, toCoordinateFrom: self.view)
        
        let lat = String(coord.latitude)
        let long = String(coord.longitude)
        latituteLabel.text = lat
        longitudeLabel.text = long
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
    }))
        self.present(alert, animated: true, completion: nil)
    }

}
