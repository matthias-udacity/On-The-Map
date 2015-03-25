//
//  StudentLocationListViewController.swift
//  On The Map
//
//  Created by Matthias on 23/03/15.
//

import UIKit

class StudentLocationListViewController: StudentLocationViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var studentTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func studentLocationsUpdated(studentLocations: [StudentLocation]) {
        studentTableView.reloadData()
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStudentLocations().count;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentTableViewCell", forIndexPath: indexPath) as UITableViewCell
        
        let studentLocation = getStudentLocations()[indexPath.row]
        cell.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"

        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = getStudentLocations()[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: studentLocation.mediaURL)!)
    }
}