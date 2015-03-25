//
//  StudentLocationClient.swift
//  On The Map
//
//  Created by Matthias on 23/03/15.
//

import Foundation

class StudentLocationClient: NSObject {

    let baseURL = "https://api.parse.com/1/classes/StudentLocation"
    let applicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

    func getStudentLocations(completionHandler: (studentLocations: [StudentLocation]?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return performGetRequest(baseURL) { jsonObject, error in
            if error != nil {
                completionHandler(studentLocations: nil, error: error)
            } else {
                // If response contains student locations, return them.
                if let jsonObject = jsonObject as? [String: AnyObject] {
                    if let results = jsonObject["results"] as? [[String: AnyObject]] {
                        var studentLocations = [StudentLocation]()

                        for result in results {
                            if let studentLocation = StudentLocation(dictionary: result) {
                                studentLocations.append(studentLocation)
                            }
                        }

                        completionHandler(studentLocations: studentLocations, error: nil)
                        return
                    }
                }

                // Otherwise, report unexpected response.
                let clientError = NSError(domain: "Parse Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response to location request."])
                completionHandler(studentLocations: nil, error: clientError)
            }
        }
    }

    func postStudentLocation(#accountKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (objectId: String?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return performPostRequest(baseURL, jsonObject: [ "uniqueKey": accountKey, "firstName": firstName, "lastName": lastName, "mapString": mapString, "mediaURL": mediaURL, "latitude": latitude, "longitude": longitude]) { jsonObject, error in
            if error != nil {
                completionHandler(objectId: nil, error: error)
            } else {
                // If response contains object id, return it.
                if let jsonObject = jsonObject as? [String: AnyObject] {
                    if let objectId = jsonObject["objectId"] as? String {
                        completionHandler(objectId: objectId, error: nil)
                        return
                    }
                }

                // Otherwise, report unexpected response.
                let clientError = NSError(domain: "Parse Error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unexpected response to location request."])
                completionHandler(objectId: nil, error: clientError)
            }
        }
    }

    private func performGetRequest(url: String, completionHandler: (jsonObject: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)

        request.addValue(applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        return performRequest(request, completionHandler)
    }

    private func performPostRequest(url: String, jsonObject: [String: AnyObject], completionHandler: (jsonObject: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)

        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(applicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

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
        completionHandler(jsonObject: NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error), error: error)
    }
}