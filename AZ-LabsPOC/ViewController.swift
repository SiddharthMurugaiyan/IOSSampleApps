//
//  ViewController.swift
//  AZ-LabsPOC
//
//  Created by Siddharth on 21/10/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,MKMapViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    //var locationManager: CLLocationManager!
    var locationManager = CLLocationManager()
    var dict :NSArray = []
    var searchText : String = ""
    var locLat :Double = 0.0
    var locLong  :Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        readJsonData()
        self.searchBar.delegate = self
        //drawRouteDirections()
        //showLabLocation()
        //simpleMapLocation()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*func testQuickUnzip() {
        do {
            let filePath = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            let destinationURL = try Zip.quickUnzipFile(filePath)
            let fileManager = FileManager.default
        }
        catch {
            
        }
    }*/
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText =  searchBar.text!
        let resultPredicate :NSPredicate = NSPredicate(format: "LabZip contains[c] %@", searchText)
        let searchResults  :NSArray = dict.filtered(using: resultPredicate) as NSArray
        if searchText == "" {
            
        }else if searchResults.count > 0  {
            dict = searchResults as NSArray
        }else if searchResults.count == 0{
             dict = searchResults as NSArray
        }
        self.tableView.reloadData()
        let dictData = dict[0]
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        showLabLocation(_addrData: dictData as! Dictionary<String, String>)
        print("Search Action \(searchResults)")
    }
    
    
    
    func simpleMapLocation(){
        let location = CLLocationCoordinate2D(
            latitude: 51.50007773,
            longitude: -0.1246402
        )
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Big Ben"
        annotation.subtitle = "London"
        mapView.addAnnotation(annotation)
    }
    
    func showRoute(){
        let request = MKDirectionsRequest()
        //request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.7127, longitude: -74.0059), addressDictionary: nil))
        
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locLat, longitude: locLong), addressDictionary: nil))
        
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.53113700, longitude: -73.74589500), addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.add(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
    }
    
    func drawRouteDirections(){
        let sourceLocation = CLLocationCoordinate2D(latitude: 40.759011, longitude: -73.984472)
        let destinationLocation = CLLocationCoordinate2D(latitude: 40.748441, longitude: -73.985564)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Times Square"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Empire State Building"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        let directionRequest = MKDirectionsRequest()
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
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
        
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("rendererFor Delegate Called")
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    
    
    func readJsonData(){
        let fileName = "AzLabs"//.json"
        if let path = Bundle.main.path(forResource:fileName, ofType: "json") {
            do {
                let data = try NSData(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe)
                let parsedData = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
                dict = (parsedData as? NSArray)!
                //let stringData = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
                if dict.count > 0 {
                    print("jsonData:\(dict[0])")
                    showLabLocation(_addrData: dict[0] as! Dictionary)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Getting the right element
        var element : [String:String] = dict[indexPath.row] as! [String : String]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LabDetailsTableViewCell
        // Adding the right informations
        cell.labName?.text = element["Lab"]
        cell.labAddress?.text = element["LabAddress"]
        cell.labCity?.text = element["LabCity"]
        cell.labState?.text = element["LabState"]
        cell.labZip?.text = element["LabZip"]
        cell.labPhone?.text = element["LabPhone"]
        cell.labFax?.text = element["LabFax"]
        // Returning the cell
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dict.count
    }
    
    func showLabLocation(_addrData:Dictionary<String, String>){
        let addrLocation = _addrData["LabAddress"]! + " " + _addrData["LabCity"]!
        let zipCode = _addrData["LabState"]! + " "  + _addrData["LabZip"]!
        let location = addrLocation + " " + zipCode //"2500 PONDVIEW SUITE 102 CASTLETON ON HUDSON, NY, and 12033"
        print("location:\( location)")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                let mark = MKPlacemark(placemark: placemark)
                self?.locLat =  location.coordinate.latitude
                self?.locLong = location.coordinate.longitude
                if var region = self?.mapView.region {
                    region.center = location.coordinate
                    region.span.longitudeDelta /= 8.0
                    region.span.latitudeDelta /= 8.0
                    self?.mapView.setRegion(region, animated: true)
                    self?.mapView.addAnnotation(mark)
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let dictData = dict[indexPath.row]
        showLabLocation(_addrData: dictData as! Dictionary<String, String>)
    }
    
    
    @IBAction func locateMe(_ sender: AnyObject) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager Current Location")
        let userLocation:CLLocation = locations[0] as CLLocation
        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpanMake(0.2,0.2)
        let region = MKCoordinateRegion(center: coordinations, span: span)
        //showRoute()
        manager.stopUpdatingLocation()
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        let location = CLLocationCoordinate2D(
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude
        )
        annotation.coordinate = location
        annotation.title = "Current Location"
        annotation.subtitle = ""
        mapView.addAnnotation(annotation)
        
    }
    
    
}

