//
//  StudentLocationMapViewController.swift
//  On The Map
//
//  Created by Matthias on 23/03/15.
//

import UIKit
import MapKit

class StudentLocationMapViewController: StudentLocationViewController, MKMapViewDelegate {

    @IBOutlet weak var studentMapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func studentLocationsUpdated(studentLocations: [StudentLocation]) {
        // Remove previous annotations.
        studentMapView.removeAnnotations(studentMapView.annotations)

        // Add current annotations.
        for studentLocation in studentLocations {
            let coordinate = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(studentLocation.latitude),
                longitude: CLLocationDegrees(studentLocation.longitude))

            var annotation = MKPointAnnotation()
            annotation.setCoordinate(coordinate)
            annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            annotation.subtitle = studentLocation.mediaURL

            self.studentMapView.addAnnotation(annotation)
        }
    }

    // MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIButton
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            UIApplication.sharedApplication().openURL(NSURL(string: view.annotation.subtitle!)!)
        }
    }
}