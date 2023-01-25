//
//  PlaceDetailViewController.swift
//  favoritePlaces_Sonia_C0872364
//
//  Created by Sonia Nain on 2023-01-24.
//

import UIKit
import CoreData

class PlaceDetailViewController: UIViewController {
    
    var selectedPlace: FavPlace?
    weak var delegate: ViewController?
    @IBOutlet weak var textView: UITextView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var subthoroughfare = selectedPlace?.subthoroughfare ?? ""
        var thoroughfare = selectedPlace?.thoroughfare ?? ""
        
        var address = subthoroughfare + " " + thoroughfare
        var locality = selectedPlace?.locality ?? ""
        var country = selectedPlace?.country ?? ""
        var postalcode = selectedPlace?.postcode ?? ""
        
        var fullAddress =  "Full Address    : " + address + ", " + locality + ", " + country + ", " + postalcode
        
        textView.text = fullAddress
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
