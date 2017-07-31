//
// SAMLAuthViewController.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import Foundation
import UIKit
import WebKit
import SAPFoundation
import SAPCommon

class SAMLAuthViewController: UIViewController, SAPURLSessionDelegate, Notifier {

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var sapUrlSession: SAPURLSession!

    private let logger = Logger.shared(named: "SAMLAuthenticationLogger")
    private let resourceURL = Constants.appUrl.appendingPathComponent("GeoLocation")
    private let authURL = Constants.sapcpmsUrl.appendingPathComponent("SAMLAuthLauncher")
    private let finishURL: URL = {
        var components = URLComponents(url: Constants.sapcpmsUrl.appendingPathComponent("SAMLAuthLauncher"), resolvingAgainstBaseURL: false)!
        components.query = "finishEndpointParam=someUnusedValue"
        return components.url!
    }()

    override func viewDidLoad() {
        setup()
        authenticate()
    }

    private func setup() {
        // Setup SAMLObserver
        let samlObserver = SAMLObserver(settingsParameters: Constants.configurationParameters)

        // Setup SAPURLSession
        sapUrlSession = SAPURLSession(delegate: self)
        sapUrlSession.register(SAPcpmsObserver(settingsParameters: Constants.configurationParameters))
        sapUrlSession.register(samlObserver)
    }

    private func authenticate() {
        self.logger.info("Authenticate with SAML.")
        let request = URLRequest(url: self.resourceURL)
        let dataTask = sapUrlSession.dataTask(with: request) { data, response, error in
            if let _ = data, let _ = response {
                self.logger.info("Successfully authenticated.")
                self.appDelegate.urlSession = self.sapUrlSession

                // Subscribe for remote notification
                self.appDelegate.registerForRemoteNotification()

                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.logger.info("Dismiss SAMLAuthViewController")
                    }
                }
            } else if let error = error {
                if let urlResponse = response as? HTTPURLResponse {
                    self.logger.error("Failed! Status: \(urlResponse.statusCode).", error: error)
                } else {
                    self.logger.error("Failed! No response.", error: error)
                }
                self.displayAlert(title: NSLocalizedString("keyErrorLogonProcessFailedNoResponseTitle",
                    value: "Logon process failed!",
                    comment: "XTIT: Title of alert message about logon process failure."),
                message: error.localizedDescription) {
                    self.authenticate()
                }
            }
        }
        dataTask.resume()
    }
}
