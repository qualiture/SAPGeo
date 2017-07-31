//
// Constants.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import Foundation
import SAPFoundation

struct Constants {

    static let appId = "com.sap.tutorials.demoapp.SAPGeo"
    // Change the SAP CP URL string below with your own
    private static let sapcpmsUrlString = "https://hcpms-<your_id_here>trial.hanatrial.ondemand.com"
    static let sapcpmsUrl = URL(string: sapcpmsUrlString)!
    static let appUrl = Constants.sapcpmsUrl.appendingPathComponent(appId)
    static let configurationParameters = SAPcpmsSettingsParameters(backendURL: Constants.sapcpmsUrl, applicationID: Constants.appId)
    
    static let geofencesKey = "geofences"
}
