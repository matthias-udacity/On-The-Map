//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Matthias on 23/03/15.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {

    var tapRecognizer: UITapGestureRecognizer!
    var latitude: Double?, longitude: Double?

    @IBOutlet weak var promptLine1Label: UILabel!
    @IBOutlet weak var promptLine2Label: UILabel!
    @IBOutlet weak var promptLine3Label: UILabel!

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!

    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var locationMapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Configure tap recognizer.
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Add tap recognizer.
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // Remove tap recognizer.
        view.removeGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func findOnTheMapButtonTouchUpInside(sender: AnyObject) {
        // Disable "Find on the Map" button.
        self.findOnTheMapButton.enabled = false

        // Display activity indicator.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // Attempt to look up location.
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text) { placemarks, error in
            dispatch_async(dispatch_get_main_queue()) {
                // Hide activity indicator.
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                if let placemarks = placemarks as? [CLPlacemark] {
                    // Hide prompt labels.
                    self.promptLine1Label.hidden = true
                    self.promptLine2Label.hidden = true
                    self.promptLine3Label.hidden = true

                    // Display link text field instead of location text field.
                    self.locationTextField.hidden = true
                    self.linkTextField.hidden = false

                    // Display map.
                    self.locationMapView.hidden = false
                    
                    // Display "Submit" button instead of "Find on the Map" button.
                    self.findOnTheMapButton.hidden = true
                    self.submitButton.hidden = false

                    for placemark in placemarks {
                        // Remember latitude and longitude.
                        self.latitude = placemark.location.coordinate.latitude
                        self.longitude = placemark.location.coordinate.longitude

                        // Add pin.
                        var annotation = MKPointAnnotation()
                        annotation.setCoordinate(placemark.location.coordinate)
                        self.locationMapView.addAnnotation(annotation)

                        // Zoom in to location.
                        var region = MKCoordinateRegion(center: placemark.location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
                        self.locationMapView.setRegion(region, animated: true)

                        break
                    }
                } else {
                    // Display error message.
                    let alert = UIAlertController(title: nil, message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    // Enable "Find on the Map" button.
                    self.findOnTheMapButton.enabled = true
                }
            }
        }
    }

    @IBAction func submitButtonTouchUpInside(sender: AnyObject) {
        // Display error message if URL is not valid.
        let url = NSURL(string: linkTextField.text)

        if url == nil || !NSURLConnection.canHandleRequest(NSURLRequest(URL: url!)) {
            let alert = UIAlertController(title: nil, message: "Please enter a valid URL.pri", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }

        // Disable "Submit" button.
        self.submitButton.enabled = false

        // Display activity indicator.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)

        // Post location.
        let client = StudentLocationClient()
        client.postStudentLocation(accountKey: appDelegate.session!.accountKey, firstName: appDelegate.account!.firstName, lastName: appDelegate.account!.lastName, mapString: locationTextField.text, mediaURL: linkTextField.text, latitude: latitude!, longitude: longitude!) { objectId, error in
            dispatch_async(dispatch_get_main_queue()) {
                // Hide activity indicator.
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if error != nil {
                    // Display error message.
                    let alert = UIAlertController(title: nil, message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    // Enable "Submit" button.
                    self.submitButton.enabled = true
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    // MARK: Tap Recognizer

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}