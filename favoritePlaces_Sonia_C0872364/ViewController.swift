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
    
    var favPlaces = [FavPlace]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
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
    
    
    
}

