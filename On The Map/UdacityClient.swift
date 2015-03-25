//
//  UdacityClient.swift
//  On The Map
//
//  Created by Matthias on 23/03/15.
//

import Foundation

struct UdacitySession {
    var accountKey: String, sessionId: String
}

struct UdacityAccount {
    var firstName: String, lastName: String
}

class UdacityClient: NSObject {

    let baseURL = "https://www.udacity.com/api"

    func loginAndGetAccountDetails(#username: String, password: String, completionHandler: (session: UdacitySession?, account: UdacityAccount?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return login(username: username, password: password) { session, error in
            if error != nil {
                completionHandler(session: nil, account: nil, error: error)
            } else {
                self.getAccountDetails(session!) { account, error in
                    if error != nil {
                        completionHandler(session: session, account: nil, error: error)
                    } else {
                        completionHandler(session: session, account: account, error: error)
                    }
                }
            }
        }
    }

    func login(#username: String, password: String, completionHandler: (session: UdacitySession?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return performPostRequest("\(baseURL)/session", jsonObject: [ "udacity": [ "username": username, "password": password] ]) { jsonObject, error in
            if error != nil {
                completionHandler(session: nil, error: error)
            } else {
                // If response contains account key and session id, return a UdacitySession.
                if let jsonObject = jsonObject as? [String: AnyObject] {
                    let account = jsonObject["account"] as? [String: AnyObject]
                    let session = jsonObject["session"] as? [String: AnyObject]

                    if account != nil && session != nil {
                        let accountKey = account!["key"] as? String
                        let sessionId  = session!["id"]  as? String

                        if accountKey != nil && sessionId != nil {
                            let session = UdacitySession(accountKey: accountKey!, sessionId: sessionId!)
                            completionHandler(session: session, error: nil)
                            return
                        }
                    }
                }

                // Otherwise, report unexpected response.
                let clientError = NSError(domain: "Udacity Error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unexpected response to session request."])
                completionHandler(session: nil, error: clientError)
            }
        }
    }

    func getAccountDetails(session: UdacitySession, completionHandler: (account: UdacityAccount?, error: NSError?) -> Void) -> NSURLSessionDataTask{
        return performGetRequest("\(baseURL)/users/\(session.accountKey)") { jsonObject, error in
            if error != nil {
                completionHandler(account: nil, error: error)
            } else {
                // If response contains first name and last name, return a UdacityAccount.
                if let jsonObject = jsonObject as? [String: AnyObject] {
                    let user = jsonObject["user"] as? [String: AnyObject]

                    if user != nil {
                        let firstName = user!["first_name"] as? String
                        let lastName  = user!["last_name"]  as? String

                        if firstName != nil && lastName != nil {
                            let account = UdacityAccount(firstName: firstName!, lastName: lastName!)
                            completionHandler(account: account, error: nil)
                            return
                        }
                    }
                }

                // Otherwise, report unexpected response.
                let clientError = NSError(domain: "Udacity Error", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unexpected response to user request."])
                completionHandler(account: nil, error: clientError)
            }
        }
    }

    private func performGetRequest(url: String, completionHandler: (jsonObject: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return performRequest(NSURLRequest(URL: NSURL(string: url)!), completionHandler)
    }

    private func performPostRequest(url: String, jsonObject: [String: AnyObject], completionHandler: (jsonObject: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)

        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: nil)

        return performRequest(request, completionHandler)
    }

    private func performRequest(request: NSURLRequest, completionHandler: (jsonObject: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(jsonObject: nil, error: error)
            } else {
                self.parseResponseWithCompletionHandler(data, completionHandler)
            }
        }

        task.resume()

        return task
    }

    private func parseResponseWithCompletionHandler(data: NSData, completionHandler: (jsonObject: AnyObject?, error: NSError?) -> Void) {
        var error: NSError?

        let jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data.subdataWithRange(NSMakeRange(5, data.length - 5)), options: NSJSONReadingOptions.AllowFragments, error: &error)

        if error != nil {
            completionHandler(jsonObject: nil, error: error)
        } else {
            // If response contains an error, return it.
            if let jsonObject = jsonObject as? [String: AnyObject] {
                let error = jsonObject["error"] as? String

                if error != nil {
                    let udacityError = NSError(domain: "Udacity Error", code: 1, userInfo: [NSLocalizedDescriptionKey: error!])
                    completionHandler(jsonObject: nil, error: udacityError)
                    return
                }
            }

            // Otherwise, return the JSON object as is.
            completionHandler(jsonObject: jsonObject, error: nil)
        }
    }
}