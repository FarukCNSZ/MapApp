//
//  ViewController.swift
//  HaritalarUygulamasi
//
//  Created by Faruk CANSIZ on 28.12.2022.
//

import UIKit
import MapKit
import CoreLocation //konum ayarları
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationTextLabel: UITextField!
    @IBOutlet weak var noteTextLabel: UITextField!
    //ismi kullanıcıya seçtiriyoruz4
    
    
    var locationManager = CLLocationManager() //Konum yöneticisi, konum ayarları 1
    
    var chosenLatitude : Double = 0.0 //Seçilen noktayı kaydediyoruz5
    var chosenLongitude : Double = 0.0
    
    //verileri aktarmak için8
    var chosenName = ""
    var chosenId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //Konum bulmada en iyisini yap, konum ayarları
        locationManager.requestWhenInUseAuthorization () //kullanıcıdan konumunu almak için izin istiyoruz, konum ayarları
        locationManager.startUpdatingLocation() //Konumu güncellemeyi başlat, konum ayarları
        
        //İşaretleme işlemi3
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(locationSelect(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //verileri aktarmak için8
        if chosenName != "" {
            //core datadan verileri çek
            if let uuidString = chosenId?.uuidString {
                
                //listeden daha önce kaydettiğimiz konumlara tıkladığımızda mapsView'da göstermesi için pin9
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                //Filtreleme işlemi= id'si yazacağımız argümanları olanları getir anlamında id=%@ uygulanır 
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            
                            if let name = result.value(forKey: "name") as? String {
                                annotationTitle = name
                                
                                if let note = result.value(forKey: "note") as? String {
                                    annotationSubtitle = note
                                    
                                    if let latitude = result.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                                        
                                        if let longitude = result.value(forKey: "longitude") as? Double {
                                            annotationLongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            mapView.addAnnotation(annotation)
                                            locationTextLabel.text = annotationTitle
                                            noteTextLabel.text = annotationSubtitle
                                            
                                            //eğer add butona değil de listede kaydettiğimiz herhangi bir pine gitmek istiyorsak oranın coordinatlarına götür
                                            locationManager.stopUpdatingLocation()
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch let error {
                    print("Error", error)
                }
            }
        } else {
            //listeden basmadıysa add butonuna bastıysa yeni veri eklemeye geldi
        }
    }
    
    //oluşturulan pine basıldığında sağ köşede bir detay iknou buton halinde çıksın:
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "reuseID"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button

        }
        else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //Navigasyon için kod bloğu
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if chosenName != "" {
            
            var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarkArray, Error) in
                
                if let placemarks = placemarkArray {
                    if placemarks.count > 0 {
                        
                        let newPlaceMark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: newPlaceMark)
                        item.name = self.annotationTitle
                        let launchOption = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOption)
                        
                    }
                }
                
            }
            
            
            
            
        }
    }
    

    @objc func locationSelect(gestureRecognizer : UILongPressGestureRecognizer) {
          
        if gestureRecognizer.state == .began {
            
            let touchedPoint = gestureRecognizer.location(in: mapView)
            let touchedCoordinate = mapView.convert(touchedPoint, toCoordinateFrom: mapView)
            
            chosenLatitude = touchedCoordinate.latitude
            chosenLongitude = touchedCoordinate.longitude
            //Seçilen noktayı kaydediyoruz5
            
            //işaretleme işlemi
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = locationTextLabel.text //ismi kullanıcıya seçtiriyoruz
            annotation.subtitle = noteTextLabel.text
            mapView.addAnnotation(annotation)
            
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Koordinatlarımızı buluyor, Konum ayarları
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        
        //Harıtayı oynatmak2 için kod blokları. Eğer add butonuna tıklanırsa bizim koordinatlarımıza git
        if chosenName == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    @IBAction func savedButton(_ sender: Any) {
         
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        newLocation.setValue(locationTextLabel.text, forKey: "name")
        newLocation.setValue(noteTextLabel.text, forKey: "note")
        newLocation.setValue(chosenLatitude, forKey: "latitude")
        newLocation.setValue(chosenLongitude, forKey: "longitude")
        newLocation.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("saved")
        } catch {
            print("error")
        }
        
        //Haritada yeni pin oluşturup kaydettikten sonra güncellenmiş listeye geri dönüyor.
        NotificationCenter.default.post(name: NSNotification.Name("LocationCreated"), object: nil)
        navigationController?.popViewController(animated: true )
        
    }
    
    
    
}

