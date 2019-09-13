//
//  ViewController.swift
//  NobelLaureatesFinder
//
//  Created by Xinbo Wu on 7/28/19.
//  Copyright © 2019 Xinbo Wu. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    @IBOutlet weak var selectYearButton: UIBarButtonItem!
    var searchButton : UIButton!
    var yearPicker : UIPickerView!
    var laureateTableView : UITableView!
    
    var timespan = Timespan.default
    var searchedLaureates: [Laureate]?
    
    lazy var mapview: MKMapView = {
        return self.view as! MKMapView
    }()
    
    lazy var laureatesDataProvider: LaureatesDataProvider? = {
        guard let fileUrl = Bundle.main.url(forResource: "nobel-prize-laureates", withExtension: "json") else {
            return nil
        }
        return LaureatesDataProvider(url: fileUrl)
    }()
    
    override func viewDidLoad() {
        self.title = "Laureates Finder"
        selectYearButton.title = "\(timespan.start) - \(timespan.end)"
        
        // Define a region for our map view with default values
        let mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(37.334922, -122.009033), span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0))
        mapview.setRegion(mapRegion, animated: true)
        
        // let's load data from database
        laureatesDataProvider?.fectchLaureates{ [unowned self] (error) in
            if error == nil {
                // loading finished
                let location =  Location(lat: mapRegion.center.latitude, lng: mapRegion.center.longitude)
                // get closest laureates with default paremeter values
                if let closestLaureates = self.laureatesDataProvider?.closestLaureates(in: location) {
                    self.searchedLaureates = closestLaureates;
                    DispatchQueue.main.async(execute: { [unowned self] in
                        self.updateView(with: closestLaureates)
                    })
                }
            } else {
                //process error
                print(error as Any)
            }
        }
    }
    
    override func loadView() {
        // Now let's create a MKMapView
        self.view = MKMapView()
        mapview.delegate = self
        
        // Now let's create and init subviews
        searchButton = UIButton(type: .system)
        searchButton.setTitle("Search with this location", for: .normal)
        searchButton.tintColor = .blue
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        searchButton.isHidden = true
        
        yearPicker = UIPickerView()
        yearPicker.backgroundColor = .white
        yearPicker.dataSource = self
        yearPicker.delegate = self
        yearPicker.isHidden = true
        
        laureateTableView = UITableView()
        laureateTableView.dataSource = self
        laureateTableView.delegate = self
        
        mapview.addSubview(searchButton)
        mapview.addSubview(yearPicker)
        mapview.addSubview(laureateTableView)
        
        // Layout subviews
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        yearPicker.translatesAutoresizingMaskIntoConstraints = false
        laureateTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            
            yearPicker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            yearPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            yearPicker.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            laureateTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            laureateTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            laureateTableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            laureateTableView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    func updateView(with laureates: Array<Laureate>) {
        //update annotations on map
        mapview.removeAnnotations(mapview.annotations)
        let annotations = laureates.map { (laureate) -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: laureate.location.lat, longitude: laureate.location.lng)
            annotation.title = laureate.firstname
            annotation.subtitle = laureate.year
            return annotation
        }
        mapview.addAnnotations(annotations)
        searchButton.isHidden = true
        //update cell for table view
        laureateTableView.reloadData()
    }
    
    @objc func search() {
        //search laureates by location of current map area
        if let closestLaureates = self.laureatesDataProvider?.closestLaureates(in: Location(lat: mapview.region.center.latitude, lng: mapview.region.center.longitude), inYears: timespan) {
            searchedLaureates = closestLaureates;
            updateView(with: closestLaureates)
        } else {
            searchedLaureates = nil
            mapview.removeAnnotations(mapview.annotations)
        }
    }
    
    @IBAction func selectYear(_ sender: UIBarButtonItem) {
        // show year picker
        yearPicker.isHidden = false
        // hide list view
        laureateTableView.isHidden = true
    }
}

// Implementaton of UIPickerViewDelegate and UIPickerViewDataSource
extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Timespan.default.end - Timespan.default.start + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(Timespan.default.start + row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            timespan.start = Timespan.default.start + row
        } else {
            timespan.end = Timespan.default.start + row
        }
        selectYearButton.title = "\(timespan.start) - \(timespan.end)"
        search()
    }
}

// Implementaton of UITableViewDataSource and UITableViewDelegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchedLaureates?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIndetifier = "cellReuseIdentifier"
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseIndetifier)
        if (cell == nil) {
           cell = UITableViewCell(style:.subtitle, reuseIdentifier:reuseIndetifier)
        }
        
        // Configure the cell...
        cell!.textLabel!.text = searchedLaureates?[indexPath.row].firstname
        cell!.detailTextLabel?.text = searchedLaureates?[indexPath.row].year
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let laureate = searchedLaureates?[indexPath.row] {
            mapview.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: laureate.location.lat, longitude: laureate.location.lng), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        }
    }
}

// Implementaton of MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        // by moving map, user can change the location and search
        yearPicker.isHidden = true
        // show table view and search button
        laureateTableView.isHidden = false
        searchButton.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "reuseIdentifier"
        var annotationView = mapview.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: nil, reuseIdentifier: reuseIdentifier)
        }
        annotationView?.annotation = annotation
        annotationView?.displayPriority = .required
        return annotationView
    }
}

