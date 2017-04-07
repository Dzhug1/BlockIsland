//
//  MapViewController.swift
//  BlockIslandTodayGit
//
//  Created by Roman Dzhugan on 4/7/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .hybrid
            mapView.showsPointsOfInterest = false
            mapView.showsBuildings = false
            mapView.showsScale = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let location = CLLocationCoordinate2DMake(41.172959, -71.558155)
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(location, 1500, 1500), animated: true)
        displayAllMarkers()
    }


    func displayAllMarkers() {
        
        let dbRef = FIRDatabase.database().reference().child("Businesses")
        
        dbRef.observe(.childAdded, with: { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let business = Business()
                business.setValuesForKeys(dictionary)
                if (business.latitute) != nil{
                    let latitude = business.latitute
                    let latitudeDouble = Double(latitude!)
                    let longitude = business.longitude
                    let longitudeDouble = Double(longitude!)
                    let title = business.businessName
                    let subtitle = business.businessDescription
                    
                    let coordinate = CLLocationCoordinate2DMake(latitudeDouble!, longitudeDouble!)
                    
                    let annotation = Annotation(title: title!, subtitle: subtitle!, coordinate: coordinate)
                    var annotations = [MKAnnotation]()
                    annotations.append(annotation)
                    self.mapView.addAnnotation(annotation as MKAnnotation)
                    self.mapView.showAnnotations([annotation], animated: true)
                }
            }
            
        })
    }

}
