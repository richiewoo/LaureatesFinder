//: A MapKit based Playground

import MapKit
import PlaygroundSupport

class MapViewController : UIViewController {
    
    var zoomInButton : UIButton!
    var zoomOutButton : UIButton!
    
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
        // Define a region for our map view
        var mapRegion = MKCoordinateRegion()
        let appleParkWayCoordinates = CLLocationCoordinate2DMake(37.334922, -122.009033)

        mapRegion.center = appleParkWayCoordinates
        mapRegion.span = MKCoordinateSpan(latitudeDelta: 100.0, longitudeDelta: 1.0)
        mapview.setRegion(mapRegion, animated: true)
        
        laureatesDataProvider?.fectchLaureates{ [unowned self] (error) in
            if let error = error {
                //process error
                print(error)
            } else {
                DispatchQueue.main.async(execute: { [unowned self] in
                    let location =  Location(lat: appleParkWayCoordinates.latitude, lng: appleParkWayCoordinates.longitude)
                    if let closestLaureates = self.laureatesDataProvider?.closestLaureates(of: 20, in: location, from: 1900, to: 2020) {
                        self.updateView(with: closestLaureates)
                    } else {
                        self.mapview.removeAnnotations(self.mapview.annotations)
                    }
                })
            }
        }
    }
    
    override func loadView() {
        // Now let's create a MKMapView
        self.view = MKMapView(frame: CGRect(x:0, y:0, width:1000, height:1000))
        mapview.delegate = self
        
        zoomInButton = UIButton(type: .system)
        zoomInButton.setTitle("Zoom in", for: .normal)
        zoomInButton.tintColor = .red
        zoomInButton.addTarget(self, action: #selector(zoom), for: .touchUpInside)
        mapview.addSubview(zoomInButton)
        
        zoomOutButton = UIButton(type: .system)
        zoomOutButton.setTitle("Zoom out", for: .normal)
        zoomOutButton.tintColor = .red
        zoomOutButton.addTarget(self, action: #selector(zoom), for: .touchUpInside)
        mapview.addSubview(zoomOutButton)
        
        // Layout
        
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            zoomInButton.topAnchor.constraint(equalTo: mapview.topAnchor, constant: 20),
            zoomInButton.leadingAnchor.constraint(equalTo: mapview.leadingAnchor, constant: 20),
            
            zoomOutButton.topAnchor.constraint(equalTo: zoomInButton.bottomAnchor, constant: 10),
            zoomOutButton.leadingAnchor.constraint(equalTo: mapview.leadingAnchor, constant: 20),
        ])
    }
    
    func updateView(with laureates: Array<Laureate>) {
        mapview.removeAnnotations(mapview.annotations)
            for laureate in laureates {
                // Create a map annotation
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: laureate.location.lat, longitude: laureate.location.lng)
                annotation.title = laureate.firstname
                annotation.subtitle = laureate.motivation
                
                mapview.addAnnotation(annotation)
            }
    }
    
    @objc func zoom(sender: UIButton!) {
        
        var changedSpan = 20.0
        if sender == zoomOutButton {
            changedSpan = -changedSpan
        }
        var mapRegion = mapview.region
        mapRegion.span = MKCoordinateSpan(latitudeDelta: mapRegion.span.latitudeDelta + changedSpan, longitudeDelta: mapRegion.span.longitudeDelta + changedSpan)
        mapview.setRegion(mapRegion, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let center = mapView.region.center
        if let closestLaureates = self.laureatesDataProvider?.closestLaureates(of: 20, in: Location(lat: center.latitude, lng: center.longitude), from: 1960, to: 2020) {
            print(closestLaureates.count)
            updateView(with: closestLaureates)
        } else {
            mapview.removeAnnotations(mapview.annotations)
        }
    }
}

// Add the created mapView to our Playground Live View
PlaygroundPage.current.liveView = MapViewController()

