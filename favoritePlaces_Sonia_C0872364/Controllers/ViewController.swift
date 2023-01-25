//
//  ViewController.swift
//  favoritePlaces_Sonia_C0872364
//
//  Created by Sonia Nain on 2023-01-24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeToolbar: UIToolbar!
    @IBOutlet weak var noPlaceView: UIView!
    
    var favPlaces = [FavPlace]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // define a search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
        showSearchBar()
        showNoPlaceView()
    }
    
    //MARK: - Core data interaction functions
    func loadPlaces(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<FavPlace> = FavPlace.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "locality", ascending: true)]
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate])
        }
        
        do {
            favPlaces = try context.fetch(request)
        } catch {
            print("Error loading tasks \(error.localizedDescription)")
        }
        
        tableView.reloadData()

    }
    
    //MARK: - show empty table view
    func showNoPlaceView(){
        if favPlaces.count == 0 {
            tableView.backgroundView = noPlaceView
            placeToolbar.isHidden = true
        }else{
            tableView.backgroundView = nil
            placeToolbar.isHidden = false
        }
    }
    
    func updatePlace(locality: String, postcode: String, country: String, thoroughfare: String, subthoroughfare: String) {
        favPlaces = []
        let newPlace = FavPlace(context: context)
        newPlace.locality = locality
        newPlace.postcode = postcode
        newPlace.country = country
        newPlace.subthoroughfare = subthoroughfare
        newPlace.thoroughfare = thoroughfare
        
        savePlace()
        loadPlaces()
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
    
    //MARK: - show search bar func
    func showSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Place"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? MapViewController {
            destination.delegate = self
        }
        
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "place_cell", for: indexPath)
        let place = favPlaces[indexPath.row]
        cell.textLabel?.text = place.locality
        cell.detailTextLabel?.text = place.postcode

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       let DeleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
           
           let alert = UIAlertController(title: "Remove this place from favourite list ", message: "Are you sure?", preferredStyle: .alert)
           let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
               self.deletePlace(place: self.favPlaces[indexPath.row])
               self.savePlace()
               self.favPlaces.remove(at: indexPath.row)
               // Delete the row from the data source
               tableView.deleteRows(at: [indexPath], with: .fade)
               self.loadPlaces()
           }
           
           let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
           alert.addAction(yesAction)
           alert.addAction(noAction)
           self.present(alert, animated: true, completion: nil)
           
           
       }
        
       let swipeActions = UISwipeActionsConfiguration(actions: [DeleteItem])

       return swipeActions
   }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let displayVC = storyboard?.instantiateViewController(withIdentifier: "PlaceDetailVC") as? PlaceDetailViewController {
    
            displayVC.delegate = self
            displayVC.selectedPlace = favPlaces[indexPath.row]
            navigationController?.pushViewController(displayVC, animated: true)
            }
    }
    
    
}

//MARK: - search bar delegate methods
extension ViewController: UISearchBarDelegate {
    
    /// search button on keypad functionality
    /// - Parameter searchBar: search bar is passed to this function
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // add predicate
        let predicate = NSPredicate(format: "locality CONTAINS[cd] %@", searchBar.text!)
        loadPlaces(predicate: predicate)
    }
    
    
    /// when the text in text bar is changed
    /// - Parameters:
    ///   - searchBar: search bar is passed to this function
    ///   - searchText: the text that is written in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadPlaces()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

