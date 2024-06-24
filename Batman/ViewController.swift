//
//  ViewController.swift
//  Batman
//
//  Created by DISMOV on 15/06/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {
    var theMap: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        theMap = MKMapView()
        theMap.frame = view.bounds
        view.addSubview(theMap)
        theMap.delegate = self
        //en simulador no funciona
        //theMap.showsUserLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataManager().getLocations { array in
            if let coordinateArray = array {
                for coord in coordinateArray {
                    self.makePin(coord, title: "Batman was here!", subtitle: "... or not?")
                }
                self.theMap.showAnnotations(self.theMap.annotations, animated: true)
                let start = coordinateArray.first!
                let end = coordinateArray.last!
                // linea con dos puntos
                // let theLine = MKPolyline(coordinates: [start, end], count: 2)
                // linea con varios puntos
                // let theLine = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count)
                // self.theMap.addOverlay(theLine)
                
                // let theArea = MKPolygon(coordinates: coordinateArray, count: coordinateArray.count)
                // self.theMap.addOverlay(theArea)
                self.getDirectionsFrom(start, to: end)
            }
        }
    }
    
    func getDirectionsFrom(_ start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        let directions = MKDirections.Request()
        directions.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        directions.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        directions.transportType = .any
        directions.requestsAlternateRoutes = true
        let routes = MKDirections(request: directions)
        routes.calculate { response, error in
            if error == nil {
                guard let routesArray = response?.routes else {return}
                guard let theRoute = routesArray.first else { return }
                self.theMap.addOverlay(theRoute.polyline)

                for route in routesArray {
                    route.polyline.title = "\(route.distance)"
                    route.polyline.subtitle = "\(route.expectedTravelTime)"
                    self.theMap.addOverlay(route.polyline)
                    
                    self.makePin(
                        route.polyline.points()[route.polyline.pointCount/2].coordinate,
                        title: "\(Int(route.distance/1000))km",
                        subtitle: "\(Int(route.expectedTravelTime/60)) minutes"
                    )
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let theRegion = MKCoordinateRegion(center: theMap.centerCoordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
        theMap.setRegion(theRegion, animated: true)
    }
    
    func makePin(_ coord: CLLocationCoordinate2D, title: String, subtitle: String) {
        let thePin = MKPointAnnotation()
        thePin.coordinate = coord
        thePin.title = title
        thePin.subtitle = subtitle
        theMap.addAnnotation(thePin)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let trazo = MKOverlayRenderer()
        if let line = overlay as? MKPolyline {
            let trazoL = MKPolylineRenderer(polyline: line)
            trazoL.strokeColor = UIColor(cgColor: CGColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1))
            trazoL.lineWidth = 2.0
            return trazoL
        } else if let poly = overlay as? MKPolygon {
             let trazoP = MKPolygonRenderer(overlay: poly)
            trazoP.strokeColor = .red
            trazoP.lineWidth = 2.0
            trazoP.fillColor = .orange
            return trazoP
        }
        return trazo
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let theAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "thePin")
        theAnnotation.glyphImage = UIImage(named: "batman")
        theAnnotation.markerTintColor = .black
        
        return theAnnotation
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if theMap.mapType == .standard {
            theMap.mapType = .satellite
        } else if theMap.mapType == .satellite {
            theMap.mapType = .hybrid
        } else {
            theMap.mapType = .standard
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        print(UIDevice.current.orientation.rawValue)
    }
}

