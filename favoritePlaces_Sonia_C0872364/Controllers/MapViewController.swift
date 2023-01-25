//
//  MapViewController.swift
//  favoritePlaces_Sonia_C0872364
//
//  Created by Sonia Nain on 2023-01-24.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapview: MKMapView!
    var locationManager = CLLocationManager()
    var userCoordinates = CLLocationCoordinate2D()
    
    weak var delegate: ViewController?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapview.showsUserLocation = true
        mapview.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        addSingleTap()

       
    }
    
    // location manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        userCoordinates = userLocation.coordinate
        let latitude = userCoordinates.latitude
        let longitude = userCoordinates.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "User Location")
        
    }
    
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String) {
        // 2 - define delta latitude and delta longitude for the span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        // 3 - creating the span and location coordinate and finally the region
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        let loc: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        // 4 - set region for the map
        mapview.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.title = title
        
        CLGeocoder().reverseGeocodeLocation(loc) { (placemarks, error) in
            if error != nil {
                print(error!)
            } else {
                if let placemark = placemarks?[0] {
                    
                    annotation.title = placemark.subThoroughfare! + " " + placemark.thoroughfare! + ", " + placemark.locality! + ", " + placemark.country!
                }
            }
        }
        
        annotation.coordinate = location
        mapview.addAnnotation(annotation)
        
    }
    
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        switch annotation.title {
        case "User Location":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            annotationView.canShowCallout = true
            return annotationView
        default:
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        }
    }
    
    //MARK: - single tap func
    func addSingleTap() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        singleTap.numberOfTapsRequired = 1
        mapview.addGestureRecognizer(singleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        let touchPoint = sender.location(in: mapview)
        let coordinate = mapview.convert(touchPoint, toCoordinateFrom: mapview)
        
        displayLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, title: "Fav Place")
      
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let viewCoordinate = view.annotation?.coordinate
        let annotationTitle = (view.annotation?.title ?? "")!
        let alertController = UIAlertController(title: "Favourite Places!", message: "Do you really want to add this to your favourite place list?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.storeDesireddataFromCoordinates(_coordinate: viewCoordinate!)
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func storeDesireddataFromCoordinates(_coordinate: CLLocationCoordinate2D){
        let latitude = _coordinate.latitude
        let longitude = _coordinate.longitude
        let loc: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(loc) { (placemarks, error) in
            if error != nil {
                print(error!)
            } else {
                if let placemark = placemarks?[0] {
                    
                    let locality = placemark.locality!
                    let postcode = placemark.postalCode!
                    self.updatePlace(locality: locality, postcode: postcode)
                }
            }
        }
        
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        
    }
    
    func updatePlace(locality: String, postcode: String) {
        let newPlace = FavPlace(context: context)
        newPlace.locality = locality
        newPlace.postcode = postcode
        
        savePlace()
    }
    
    // delete place from context
    func deletePlace(place: FavPlace) {
        context.delete(place)
    }
    
    /// Save notes into core data
    func savePlace() {
        do {
            try context.save()
        } catch {
            print("Error saving the tasks \(error.localizedDescription)")
        }
    }
    

 
}
