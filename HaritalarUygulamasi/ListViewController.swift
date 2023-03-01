//
//  ListViewController.swift
//  HaritalarUygulamasi
//
//  Created by Faruk CANSIZ on 29.12.2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet weak var tableView: UITableView!
    
    //verileri çekmek için7
    var nameArray = [String]()
    var idArray = [UUID]()
    
    //verileri aktarmak için8
    var chosenLocationName = ""
    var chosenLocationId : UUID?
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickedaAddButton))
    
        getData()
    
    }
    
    //Haritada yeni pin oluşturup kaydettikten sonra güncellenmiş listeye geri dönüyor.
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("LocationCreated"), object: nil)
    }
    
    //verileri çekmek için7
    @objc func getData () {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        
        do {
            
            let results = try context.fetch(request)
            
            nameArray.removeAll(keepingCapacity: false)
            idArray.removeAll(keepingCapacity: false)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String {
                        nameArray.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        idArray.append(id)
                    }
                    
                }
                
                tableView.reloadData()
                
            }
        } catch {
            print("Error")
        }
    }
    
    @objc func clickedaAddButton() {
        
        //verileri aktarmak için8
        chosenLocationName = ""
        
         performSegue(withIdentifier: "toMapsVC", sender: nil )
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    //verileri aktarmak için8
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenLocationName = nameArray[indexPath.row]
        chosenLocationId = idArray[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    //verileri aktarmak için8
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.chosenId = chosenLocationId
        }
    }
    
}
