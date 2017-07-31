//
// SAPGeoServiceDataAccess.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import Foundation
import SAPCommon
import SAPFoundation
import SAPOData

class SAPGeoServiceDataAccess {

    let service: SAPGeoService<OnlineODataProvider>
    private let logger = Logger.shared(named: "ServiceDataAccessLogger")

    init(urlSession: SAPURLSession) {
        let odataProvider = OnlineODataProvider(serviceName: "SAPGeoService", serviceRoot: Constants.appUrl, sapURLSession: urlSession)

        // Disables version validation of the backend OData service
        // TODO: Should only be used in demo and test applications
        odataProvider.serviceOptions.checkVersion = false

        self.service = SAPGeoService(provider: odataProvider)

        // To update entity force to use X-HTTP-Method header
        self.service.provider.networkOptions.tunneledMethods.append("MERGE")
    }

    func loadGeoLocation(completionHandler: @escaping([GeoLocationType]?, Error?) -> ()) {
        self.executeRequest(self.service.geoLocation, completionHandler)
    }

    // MARK: - Request execution
    private typealias DataAccessCompletionHandler<Entity> = ([Entity]?, Error?) -> ()
    private typealias DataAccessRequestWithQuery<Entity> = (DataQuery, @escaping DataAccessCompletionHandler<Entity>) -> ()

    /// Helper function to execute a given request.
    /// Provides error logging and extends the query so that it only requests the first 20 items.
    ///
    /// - Parameter request: the request to execute
    private func executeRequest<Entity: EntityValue>(_ request: DataAccessRequestWithQuery<Entity>, _ completionHandler: @escaping DataAccessCompletionHandler<Entity>) {

        // Only request the first 20 values
        let query = DataQuery().selectAll().top(20)

        request(query) { (result, error) in
            guard let result = result else {
                let error = error!
                self.logger.error("Error happened in the downloading process.", error: error)
                completionHandler(nil, error)
                return
            }
            completionHandler(result, nil)
        }
    }
}
