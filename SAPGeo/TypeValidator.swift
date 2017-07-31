//
// TypeValidator.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import SAPOData

class TypeValidator {

    // Check string if it can be converted to one of the supported valid Date formats
    static func validGlobalDateTime(from input: String) -> GlobalDateTime? {
        return GlobalDateTime.parse(input)
    }

    // Check string if it can be converted to one of the supported valid Date formats
    static func validLocalDateTime(from input: String) -> LocalDateTime? {
        return LocalDateTime.parse(input)
    }

    // Check string if it can be converted to edm.decimal
    static func validBigDecimal(from input: String) -> BigDecimal? {
        return BigDecimal.parse(input)
    }

    // Check string if it can be converted to edm.int
    static func validInteger(from input: String) -> Int? {
        return Int(input)
    }

    // Check string if it can be converted to edm.long
    static func validInt64(from input: String) -> Int64? {
        return Int64(input)
    }

    // Check string if it can be converted to edm.integer
    static func validBigInteger(from input: String) -> BigInteger? {
        return BigInteger.parse(input)
    }

    // Check string if it can be converted to edm.double
    static func validDouble(from input: String) -> Double? {
        return Double(input)
    }

    // Check string if it can be converted to edm.float
    static func validFloat(from input: String) -> Float? {
        return Float(input)
    }

    // Check string if it can be converted to edm.guid
    static func validGuid(from input: String) -> GuidValue? {
        return GuidValue.parse(input)
    }

    // Check string if it can be converted to edm.boolean
    // Odata 2/3/4 should be supported
    // Swift only supports true/false casting, but odata needs 0/1 also
    static func validBoolean(from input: String) -> Bool? {
        return input.toBool()
    }

    // Check if string is empty in cases, when property is not optional
    static func validString(from input: String, for property: Property) -> String? {
        if !property.isOptional && input == "" {
            return nil
        } else {
            return input
        }
    }
}

// String type only converts true/false but 0/1 strings don't,
// so we have to extend it and use when we want to convert string to edm.boolean
extension String {

    func toBool() -> Bool? {
        switch self.lowercased() {
        case "true", "1":
            return true
        case "false", "0":
            return false
        default:
            return nil
        }
    }
}
