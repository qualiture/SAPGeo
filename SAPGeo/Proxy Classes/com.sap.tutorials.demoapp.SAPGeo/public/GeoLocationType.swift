// # Proxy Compiler 17.5.3-9e1425-20170523

import Foundation
import SAPOData

open class GeoLocationType: EntityValue {
    public static let id: Property = SAPGeoServiceMetadata.EntityTypes.geoLocationType.property(withName: "ID")

    public static let title: Property = SAPGeoServiceMetadata.EntityTypes.geoLocationType.property(withName: "Title")

    public static let description: Property = SAPGeoServiceMetadata.EntityTypes.geoLocationType.property(withName: "Description")

    public static let longitude: Property = SAPGeoServiceMetadata.EntityTypes.geoLocationType.property(withName: "Longitude")

    public static let latitude: Property = SAPGeoServiceMetadata.EntityTypes.geoLocationType.property(withName: "Latitude")

    public static let radius: Property = SAPGeoServiceMetadata.EntityTypes.geoLocationType.property(withName: "Radius")

    public init() {
        super.init(type: SAPGeoServiceMetadata.EntityTypes.geoLocationType)
    }

    open class func array(from: EntityValueList) -> Array<GeoLocationType> {
        return ArrayConverter.convert(from.toArray(), Array<GeoLocationType>())
    }

    open func copy() -> GeoLocationType {
        return CastRequired<GeoLocationType>.from(self.copyEntity())
    }

    open var description: String? {
        get {
            return StringValue.optional(self.dataValue(for: GeoLocationType.description))
        }
        set(value) {
            self.setDataValue(for: GeoLocationType.description, to: StringValue.of(optional: value))
        }
    }

    open var id: String {
        get {
            return StringValue.unwrap(self.dataValue(for: GeoLocationType.id))
        }
        set(value) {
            self.setDataValue(for: GeoLocationType.id, to: StringValue.of(value))
        }
    }

    open class func key(id: String) -> EntityKey {
        return EntityKey().with(name: "ID", value: StringValue.of(id))
    }

    open var latitude: Double? {
        get {
            return DoubleValue.optional(self.dataValue(for: GeoLocationType.latitude))
        }
        set(value) {
            self.setDataValue(for: GeoLocationType.latitude, to: DoubleValue.of(optional: value))
        }
    }

    open var longitude: Double? {
        get {
            return DoubleValue.optional(self.dataValue(for: GeoLocationType.longitude))
        }
        set(value) {
            self.setDataValue(for: GeoLocationType.longitude, to: DoubleValue.of(optional: value))
        }
    }

    open var old: GeoLocationType {
        get {
            return CastRequired<GeoLocationType>.from(self.oldEntity)
        }
    }

    open var radius: Double? {
        get {
            return DoubleValue.optional(self.dataValue(for: GeoLocationType.radius))
        }
        set(value) {
            self.setDataValue(for: GeoLocationType.radius, to: DoubleValue.of(optional: value))
        }
    }

    open var title: String? {
        get {
            return StringValue.optional(self.dataValue(for: GeoLocationType.title))
        }
        set(value) {
            self.setDataValue(for: GeoLocationType.title, to: StringValue.of(optional: value))
        }
    }
}
