//
//  ViewController.swift
//  MyLocation
//
//  Created by Janarthan Subburaj on 21/12/20.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,  UISearchBarDelegate, MKMapViewDelegate {

    @IBOutlet weak var MyMapKitView: MKMapView!
    var SourceLocation:CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    //location access granted ,check it
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func setupLocationManager() {
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            MyMapKitView.setRegion(region, animated: true)
        }
    }
    
    
    
    
    
  
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            print("Show alert letting the user know they have to turn this on.")
        }
    }
    
    
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            MyMapKitView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
    
    @IBAction func SearchAction(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil
            {
                print("ERROR")
            }
            else
            {
                let annotations = self.MyMapKitView.annotations
                self.MyMapKitView.removeAnnotations(annotations)
                
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.MyMapKitView.addAnnotation(annotation)
                
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                
                let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 9.5139, longitude: 78.1002), addressDictionary: nil)
                let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(latitude!, longitude!), addressDictionary: nil)

                let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

                let sourceAnnotation = MKPointAnnotation()

                if let location = sourcePlacemark.location {
                    sourceAnnotation.coordinate = location.coordinate
                }

                let destinationAnnotation = MKPointAnnotation()

                if let location = destinationPlacemark.location {
                    destinationAnnotation.coordinate = location.coordinate
                }

                self.MyMapKitView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

                let directionRequest = MKDirections.Request()
                directionRequest.source = sourceMapItem
                directionRequest.destination = destinationMapItem
                directionRequest.transportType = .automobile

                let directions = MKDirections(request: directionRequest)

                directions.calculate {
                    (response, error) -> Void in

                    guard let response = response else {
                        if let error = error {
                            print("Error: \(error)")
                        }

                        return
                    }

                    let route = response.routes[0]

                    self.MyMapKitView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

                    let rect = route.polyline.boundingMapRect
                    self.MyMapKitView.setRegion(MKCoordinateRegion(rect), animated: true)
                }
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.MyMapKitView.setRegion(region, animated: true)
            }
            
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let renderer = MKPolylineRenderer(overlay: overlay)

        renderer.strokeColor = UIColor.systemGray3

        renderer.lineWidth = 5.0

        return renderer
    }
}
    extension ViewController: CLLocationManagerDelegate {
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            MyMapKitView.setRegion(region, animated: true)
        }
        
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
        }
        
        
    }



