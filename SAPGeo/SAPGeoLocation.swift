//
//  SAPGeoLocation.swift
//  SAPGeo
//
//  Created by Robin van het Hof on 14/06/2017.
//  Copyright © 2017 SAP. All rights reserved.
//

import MapKit
import CoreLocation

class SAPGeoLocation: NSObject, NSCoding, MKAnnotation {
    let identifier: String
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let radius: Double
    
    init(geoLocationType: GeoLocationType) {
        self.identifier = geoLocationType.id
        self.title      = geoLocationType.title
        self.subtitle   = geoLocationType.description
        self.coordinate = CLLocationCoordinate2D(latitude: geoLocationType.latitude!, longitude: geoLocationType.longitude!)
        self.radius     = geoLocationType.radius!
    }
    
    required init?(coder aDecoder: NSCoder) {
        identifier    = aDecoder.decodeObject(forKey: SAPGeoLocationKey.identifier) as! String
        title         = aDecoder.decodeObject(forKey: SAPGeoLocationKey.title) as? String
        subtitle      = aDecoder.decodeObject(forKey: SAPGeoLocationKey.subtitle) as? String
        let latitude  = aDecoder.decodeDouble(forKey: SAPGeoLocationKey.latitude)
        let longitude = aDecoder.decodeDouble(forKey: SAPGeoLocationKey.longitude)
        coordinate    = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius        = aDecoder.decodeDouble(forKey: SAPGeoLocationKey.radius)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: SAPGeoLocationKey.identifier)
        aCoder.encode(title, forKey: SAPGeoLocationKey.title)
        aCoder.encode(subtitle, forKey: SAPGeoLocationKey.subtitle)
        aCoder.encode(coordinate.latitude, forKey: SAPGeoLocationKey.latitude)
        aCoder.encode(coordinate.longitude, forKey: SAPGeoLocationKey.longitude)
        aCoder.encode(radius, forKey: SAPGeoLocationKey.radius)
    }
}

struct SAPGeoLocationKey {
    static let identifier = "identifier"
    static let title      = "title"
    static let subtitle   = "subtitle"
    static let latitude   = "latitude"
    static let longitude  = "longitude"
    static let radius     = "radius"
}
