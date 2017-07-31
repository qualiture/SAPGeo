//
// CollectionType.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import Foundation

enum CollectionType: String {

    case geoLocation = "GeoLocation"
    case none = ""

    private static let all = [
        geoLocation]

    static let allValues = CollectionType.all.map { (type) -> String in
        return type.rawValue
    }
}
