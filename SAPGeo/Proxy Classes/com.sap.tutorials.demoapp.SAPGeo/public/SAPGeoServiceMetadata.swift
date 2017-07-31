// # Proxy Compiler 17.5.3-9e1425-20170523

import Foundation
import SAPOData

public class SAPGeoServiceMetadata {
    public static let source: String = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\" ?><edmx:Edmx Version=\"1.0\" xmlns:edmx=\"http://schemas.microsoft.com/ado/2007/06/edmx\"><edmx:DataServices xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" m:DataServiceVersion=\"2.0\"><Schema Namespace=\"sapgeo.SAPGeoService\" xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns=\"http://schemas.microsoft.com/ado/2008/09/edm\"><EntityType Name=\"GeoLocationType\"><Key><PropertyRef Name=\"ID\" /></Key><Property Name=\"ID\" Type=\"Edm.String\" Nullable=\"false\" MaxLength=\"36\" /><Property Name=\"Title\" Type=\"Edm.String\" MaxLength=\"32\" /><Property Name=\"Description\" Type=\"Edm.String\" MaxLength=\"256\" /><Property Name=\"Longitude\" Type=\"Edm.Double\" /><Property Name=\"Latitude\" Type=\"Edm.Double\" /><Property Name=\"Radius\" Type=\"Edm.Double\" /></EntityType><EntityContainer Name=\"SAPGeoService\" m:IsDefaultEntityContainer=\"true\"><EntitySet Name=\"GeoLocation\" EntityType=\"sapgeo.SAPGeoService.GeoLocationType\" /></EntityContainer></Schema></edmx:DataServices></edmx:Edmx>\n"

    internal static let parsed: CSDLDocument = SAPGeoServiceMetadata.parse()

    public static let document: CSDLDocument = SAPGeoServiceMetadata.resolve()

    static func parse() -> CSDLDocument {
        let parser: CSDLParser = CSDLParser()
        parser.logWarnings = false
        parser.csdlOptions = (CSDLOption.processMixedVersions | CSDLOption.retainOriginalText | CSDLOption.ignoreUndefinedTerms)
        return parser.parseInProxy(SAPGeoServiceMetadata.source, url: "sapgeo.SAPGeoService")
    }

    static func resolve() -> CSDLDocument {
        SAPGeoServiceMetadata.EntityTypes.geoLocationType.registerFactory(ObjectFactory.with(create: { GeoLocationType() }))
        return SAPGeoServiceMetadata.parsed
    }

    public class EntityTypes {
        public static let geoLocationType: EntityType = SAPGeoServiceMetadata.parsed.entityType(withName: "sapgeo.SAPGeoService.GeoLocationType")
    }

    public class EntitySets {
        public static let geoLocation: EntitySet = SAPGeoServiceMetadata.parsed.entitySet(withName: "GeoLocation")
    }
}
