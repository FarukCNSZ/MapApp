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
    
    @IBOutlet weak var yerTextLabel: UITextField!
    @IBOutlet weak var notTextLabel: UITextField!
    //ismi kullanıcıya seçtiriyoruz4
    
    @IBOutlet weak var kaydetButon: UIButton!
    
    var locationManager = CLLocationManager() //Konum yöneticisi, konum ayarları 1
    
    var secilenLatitude : Double = 0.0 //Seçilen noktayı kaydediyoruz5
    var secilenLongitude : Double = 0.0
    
    //verileri aktarmak için8
    var secilenIsim = ""
    var secilenId : UUID?
    
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
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer )
        
        //verileri aktarmak için8
        if secilenIsim != "" {
            //core datadan verileri çek
            if let uuidString = secilenId?.uuidString {
                
                //listeden daha önce kaydettiğimiz konumlara tıkladığımızda mapsView'da göstermesi için pin9
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                //Filtreleme işlemi= id'si yazacağımız argümanları olanları getir anlamında id=%@ uygulanır 
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            
                            if let isim = sonuc.value(forKey: "isim") as? String {
                                annotationTitle = isim
                                
                                if let not = sonuc.value(forKey: "not") as? String {
                                    annotationSubtitle = not
                                    
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                                        
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double {
                                            annotationLongitude = longitude
                                        }
                                    }
                                }
                            } 
                            let annotation = MKPointAnnotation()
                            annotation.title = annotationTitle
                            annotation.subtitle = annotationSubtitle
                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                            annotation.coordinate = coordinate
                            mapView.addAnnotation(annotation)
                            yerTextLabel.text = annotationTitle
                            notTextLabel.text = annotationSubtitle
                            
                            //eğer add butona değil de listede kaydettiğimiz herhangi bir pine gitmek istiyorsak oranın coordinatlarına götür
                            locationManager.startUpdatingLocation()
                            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                            let region = MKCoordinateRegion(center: coordinate, span: span)
                            mapView.setRegion(region, animated: true)
                            
                        }
                    }
                } catch {
                    
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
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            
            let buton = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = buton

        }
        else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //Navigasyon için kod bloğu
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilenIsim != "" {
            
            let location = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(location) { placemarkDizisi, Hata in
                
                if let placemarks = placemarkDizisi {
                    if placemarks.count > 0 {
                        
                        let yeniPlaceMark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlaceMark)
                        item.name = self.annotationTitle
                        let launchOption = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOption)
                        
                    }
                }
                
            }
            
            
            
            
        }
    }
    

    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer) {
          
        if gestureRecognizer.state == .began {
            
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            //Seçilen noktayı kaydediyoruz5
            
            //işaretleme işlemi
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat
            annotation.title = yerTextLabel.text //ismi kullanıcıya seçtiriyoruz
            annotation.subtitle = notTextLabel.text
            mapView.addAnnotation(annotation)
            
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Koordinatlarımızı buluyor, Konum ayarları
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        
        //Harıtayı oynatmak2 için kod blokları. Eğer add butonuna tıklanırsa bizim koordinatlarımıza git
        if secilenIsim == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func kaydetButton(_ sender: Any) {
         
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        
        yeniYer.setValue(yerTextLabel.text, forKey: "isim")
        yeniYer.setValue(notTextLabel.text, forKey: "not")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("kaydedildi")
        } catch {
            print("hata")
        }
        
        //Haritada yeni pin oluşturup kaydettikten sonra güncellenmiş listeye geri dönüyor.
        NotificationCenter.default.post(name: NSNotification.Name("YerOlusturuldu"), object: nil)
        navigationController?.popViewController(animated: true )
        
    }
    
    
    
}

