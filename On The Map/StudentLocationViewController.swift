//
//  StudentLocationViewController.swift
//  On The Map
//
//  Created by Matthias on 23/03/15.
//

import UIKit

class StudentLocationViewController: UIViewController {

    @IBOutlet weak var refreshBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)

        if appDelegate.studentLocations.isEmpty {
            updateStudentLocations()
        } else {
            studentLocationsUpdated(appDelegate.studentLocations)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getStudentLocations() -> [StudentLocation] {
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        return appDelegate.studentLocations;
    }

    func updateStudentLocations() {
        refreshBarButtonItem.enabled = false

        let client = StudentLocationClient()
        client.getStudentLocations { studentLocations, error in
            if let studentLocations = studentLocations {
                let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                appDelegate.studentLocations = studentLocations

                dispatch_async(dispatch_get_main_queue()) {
                    self.studentLocationsUpdated(appDelegate.studentLocations)
                    self.refreshBarButtonItem.enabled = true
                }
            } else {
                let alert = UIAlertController(title: nil, message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    func studentLocationsUpdated(studentLocations: [StudentLocation]) {
    }

    // MARK: IBActions

    @IBAction func pinBarButtonItemClicked(sender: AnyObject) {
        performSegueWithIdentifier("informationPostingSegue", sender: nil)
    }

    @IBAction func refreshBarButtonItemClicked(sender: AnyObject) {
        updateStudentLocations()
    }
}