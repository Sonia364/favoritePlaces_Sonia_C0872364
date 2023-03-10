//
//  MapViewController.swift
//  favoritePlaces_Sonia_C0872364
//
//  Created by Sonia Nain on 2023-01-24.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapview: MKMapView!
    var locationManager = CLLocationManager()
    var userCoordinates = CLLocationCoordinate2D()
    
    weak var delegate: ViewController?
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapview.showsUserLocation = true
        mapview.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        addSingleTap()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        locationSearchTable.mapView = mapview
        locationSearchTable.handleMapSearchDelegate = self

       
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
        
        
        CLGeocoder().reverseGeocodeLocation(loc) { (placemarks, error) in
            if error != nil {
                print(error!)
            } else {
                if let placemark = placemarks?[0] {
                    
                    annotation.title = placemark.subLocality! + ", " + placemark.locality! + ", " + placemark.country!
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
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.markerTintColor = UIColor.blue
            return annotationView
        default:
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.isDraggable = true
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
        
        removePin()
        
        let touchPoint = sender.location(in: mapview)
        let coordinate = mapview.convert(touchPoint, toCoordinateFrom: mapview)
        
        displayLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, title: "Fav Place")
      
    }
    
    //MARK: - remove pin from map
    func removePin() {
        for annotation in mapview.annotations {
            mapview.removeAnnotation(annotation)
        }
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
                    
                    let locality = placemark.locality ?? " "
                    let postcode = placemark.postalCode ?? " "
                    let country = placemark.country ?? " "
                    let subThoroughfare  = placemark.subThoroughfare ?? " "
                    let thoroughfare = placemark.thoroughfare ?? " "
                    self.delegate?.updatePlace(locality: locality, postcode: postcode, country: country, thoroughfare: thoroughfare, subthoroughfare: subThoroughfare)
                }
            }
        }
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.showNoPlaceView()
        delegate?.loadPlaces()
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            let coordinates = view.annotation?.coordinate
            displayLocation(latitude: coordinates!.latitude, longitude: coordinates!.longitude, title: "Fav Place")
            view.dragState = .none
            
        default: break
        }
    }

 
}

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapview.setRegion(region, animated: true)
        let coordinates = placemark.coordinate
        displayLocation(latitude: coordinates.latitude, longitude: coordinates.longitude, title: "Fav Place")
    }
}
