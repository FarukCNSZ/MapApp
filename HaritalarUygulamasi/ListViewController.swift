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
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    //verileri aktarmak için8
    var secilenYerİsmi = ""
    var secilenYerId : UUID?
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButonTiklandi))
    
        veriAl()
    
    }
    
    //Haritada yeni pin oluşturup kaydettikten sonra güncellenmiş listeye geri dönüyor.
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(veriAl), name: NSNotification.Name("YerOlusturuldu"), object: nil)
    }
    
    //verileri çekmek için7
    @objc func veriAl () {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        
        do {
            
            let sonuclar = try context.fetch(request)
            
            isimDizisi.removeAll(keepingCapacity: false)
            idDizisi.removeAll(keepingCapacity: false)
            
            if sonuclar.count > 0 {
                
                for sonuc in sonuclar as! [NSManagedObject] {
                    
                    if let isim = sonuc.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                    
                }
                
                tableView.reloadData()
                
            }
        } catch {
            print("hata")
        }
    }
    
    @objc func addButonTiklandi () {
        
        //verileri aktarmak için8
        secilenYerİsmi = ""
        
         performSegue(withIdentifier: "toMapsVC", sender: nil )
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
    }
    
    //verileri aktarmak için8
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYerİsmi = isimDizisi[indexPath.row]
        secilenYerId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    //verileri aktarmak için8
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.secilenIsim = secilenYerİsmi
            destinationVC.secilenId = secilenYerId
        }
    }
    
}
