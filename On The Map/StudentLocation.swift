//
//  StudentLocation.swift
//  On The Map
//
//  Created by Matthias on 24/03/15.
//

import Foundation

struct StudentLocation {

    let firstName: String, lastName: String
    let latitude: Double, longitude: Double
    let mediaURL: String

    init?(dictionary: [String: AnyObject]) {
        if let lastName  = dictionary["lastName"] as? String {
            self.lastName = lastName
        } else {
            return nil
        }

        if let firstName = dictionary["firstName"] as? String {
            self.firstName = firstName
        } else {
            return nil
        }

        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = latitude
        } else {
            return nil
        }

        if let longitude = dictionary["longitude"] as? Double {
            self.longitude = longitude
        } else {
            return nil
        }

        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = mediaURL
        } else {
            return nil
        }
    }
}