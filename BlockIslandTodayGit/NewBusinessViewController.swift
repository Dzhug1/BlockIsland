//
//  NewBusinessViewController.swift
//  BlockIslandTodayGit
//
//  Created by Roman Dzhugan on 4/4/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit

class NewBusinessViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var categoryField: UITextField!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    var categories = ["Restaurant", "Taxi", "Hotel", "Shop"]
    var imageArray = [UIImage]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
        
        imageArray = [#imageLiteral(resourceName: "Profile"), #imageLiteral(resourceName: "Map"), #imageLiteral(resourceName: "Ferry Schedule"), #imageLiteral(resourceName: "Images 100")]
        
        for i in 0..<imageArray.count{
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            let xPosition = imageScrollView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height)
            
            imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(i + 1)
            imageScrollView.addSubview(imageView)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
