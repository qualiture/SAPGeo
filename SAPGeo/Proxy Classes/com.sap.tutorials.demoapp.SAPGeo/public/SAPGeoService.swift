// # Proxy Compiler 17.5.3-9e1425-20170523

import Foundation
import SAPOData

open class SAPGeoService<Provider: DataServiceProvider>: DataService<Provider> {

    public override init(provider: Provider) {
        super.init(provider: provider)
        self.provider.metadata = SAPGeoServiceMetadata.document
    }

    open func geoLocation(query: DataQuery = DataQuery()) throws -> Array<GeoLocationType> {
        return try GeoLocationType.array(from: self.executeQuery(query.from(SAPGeoServiceMetadata.EntitySets.geoLocation)).entityList())
    }

    open func geoLocation(query: DataQuery = DataQuery(), completionHandler: @escaping(Array<GeoLocationType>?, Error?) -> Void) -> Void {
        self.addBackgroundOperation {
            do {
                let result: Array<GeoLocationType> = try self.geoLocation(query: query)
                OperationQueue.main.addOperation {
                    completionHandler(result, nil)
                }
            }
            catch let error {
                OperationQueue.main.addOperation {
                    completionHandler(nil, error)
                }
            }
        }
    }
}
