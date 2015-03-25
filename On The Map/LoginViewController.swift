//
//  LoginViewController.swift
//  On The Map
//
//  Created by Matthias on 23/03/15.
//

import UIKit

class LoginViewController: UIViewController {

    var tapRecognizer: UITapGestureRecognizer!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

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

    // MARK: IBActions

    @IBAction func loginButtonTouchUpInside(sender: UIButton) {
        // Disable "Login" button.
        loginButton.enabled = false

        // Display activity indicator.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // Attempt to log in using provided credentials.
        let client = UdacityClient()
        client.loginAndGetAccountDetails(username: emailTextField.text, password: passwordTextField.text) { session, account, error in
            dispatch_async(dispatch_get_main_queue()) {
                // Hide activity indicator.
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                if error != nil {
                    // Display error message.
                    let alert = UIAlertController(title: nil, message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    // Enable "Login" button.
                    self.loginButton.enabled = true
                } else {
                    // Store session and account in AppDelegate.
                    let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
                    appDelegate.session = session
                    appDelegate.account = account

                    // Perform "loginSegue".
                    self.performSegueWithIdentifier("loginSegue", sender: nil)
                }
            }
        }
    }

    @IBAction func signUpButtonTouchUpInside(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }

    // MARK: Tap Recognizer

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}