//
// GeoLocationTypeDetailTableDelegate.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//
import Foundation
import UIKit
import SAPOData
import SAPCommon

class GeoLocationTypeDetailTableDelegate: NSObject, DetailTableDelegate {
    private let dataAccess: SAPGeoServiceDataAccess
    private var _entity: GeoLocationType?
    var entity: EntityValue {
        get {
            if _entity == nil {
                _entity = createEntityWithDefaultValues()
            }
            return _entity!
        }
        set {
            _entity = newValue as? GeoLocationType
        }
    }
    var rightBarButton: UIBarButtonItem
    private var validity = Array(repeating: true, count: 6)

    init(dataAccess: SAPGeoServiceDataAccess, rightBarButton: UIBarButtonItem) {
        self.dataAccess = dataAccess
        self.rightBarButton = rightBarButton
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentEntity = self.entity as? GeoLocationType else {
            return cellForDefault(tableView: tableView, indexPath: indexPath)
        }
        switch indexPath.row {
        case 0:
            var value = ""
            if currentEntity.hasDataValue(for: GeoLocationType.id) {
                value = "\(currentEntity.id)"
            }
            return cellForProperty(tableView: tableView, indexPath: indexPath, property: GeoLocationType.id, value: value, changeHandler: { (newValue: String) -> Bool in
                if let validValue = TypeValidator.validString(from: newValue, for: GeoLocationType.id) {
                    currentEntity.id = validValue
                    self.validity[0] = true
                } else {
                    self.validity[0] = false
                }
                self.barButtonShouldBeEnabled()
                return self.validity[0]
            })
        case 1:
            var value = ""
            if currentEntity.hasDataValue(for: GeoLocationType.title) {
                if let title = currentEntity.title {
                    value = "\(title)"
                }
            }
            return cellForProperty(tableView: tableView, indexPath: indexPath, property: GeoLocationType.title, value: value, changeHandler: { (newValue: String) -> Bool in
                // The property is optional, so nil value can be accepted
                if newValue.isEmpty {
                    currentEntity.title = nil
                    self.validity[1] = true
                } else {
                    if let validValue = TypeValidator.validString(from: newValue, for: GeoLocationType.title) {
                        currentEntity.title = validValue
                        self.validity[1] = true
                    } else {
                        self.validity[1] = false
                    }
                }
                self.barButtonShouldBeEnabled()
                return self.validity[1]
            })
        case 2:
            var value = ""
            if currentEntity.hasDataValue(for: GeoLocationType.description) {
                if let description = currentEntity.description {
                    value = "\(description)"
                }
            }
            return cellForProperty(tableView: tableView, indexPath: indexPath, property: GeoLocationType.description, value: value, changeHandler: { (newValue: String) -> Bool in
                // The property is optional, so nil value can be accepted
                if newValue.isEmpty {
                    currentEntity.description = nil
                    self.validity[2] = true
                } else {
                    if let validValue = TypeValidator.validString(from: newValue, for: GeoLocationType.description) {
                        currentEntity.description = validValue
                        self.validity[2] = true
                    } else {
                        self.validity[2] = false
                    }
                }
                self.barButtonShouldBeEnabled()
                return self.validity[2]
            })
        case 3:
            var value = ""
            if currentEntity.hasDataValue(for: GeoLocationType.longitude) {
                if let longitude = currentEntity.longitude {
                    value = "\(longitude)"
                }
            }
            return cellForProperty(tableView: tableView, indexPath: indexPath, property: GeoLocationType.longitude, value: value, changeHandler: { (newValue: String) -> Bool in
                // The property is optional, so nil value can be accepted
                if newValue.isEmpty {
                    currentEntity.longitude = nil
                    self.validity[3] = true
                } else {
                    if let validValue = TypeValidator.validDouble(from: newValue) {
                        currentEntity.longitude = validValue
                        self.validity[3] = true
                    } else {
                        self.validity[3] = false
                    }
                }
                self.barButtonShouldBeEnabled()
                return self.validity[3]
            })
        case 4:
            var value = ""
            if currentEntity.hasDataValue(for: GeoLocationType.latitude) {
                if let latitude = currentEntity.latitude {
                    value = "\(latitude)"
                }
            }
            return cellForProperty(tableView: tableView, indexPath: indexPath, property: GeoLocationType.latitude, value: value, changeHandler: { (newValue: String) -> Bool in
                // The property is optional, so nil value can be accepted
                if newValue.isEmpty {
                    currentEntity.latitude = nil
                    self.validity[4] = true
                } else {
                    if let validValue = TypeValidator.validDouble(from: newValue) {
                        currentEntity.latitude = validValue
                        self.validity[4] = true
                    } else {
                        self.validity[4] = false
                    }
                }
                self.barButtonShouldBeEnabled()
                return self.validity[4]
            })
        case 5:
            var value = ""
            if currentEntity.hasDataValue(for: GeoLocationType.radius) {
                if let radius = currentEntity.radius {
                    value = "\(radius)"
                }
            }
            return cellForProperty(tableView: tableView, indexPath: indexPath, property: GeoLocationType.radius, value: value, changeHandler: { (newValue: String) -> Bool in
                // The property is optional, so nil value can be accepted
                if newValue.isEmpty {
                    currentEntity.radius = nil
                    self.validity[5] = true
                } else {
                    if let validValue = TypeValidator.validDouble(from: newValue) {
                        currentEntity.radius = validValue
                        self.validity[5] = true
                    } else {
                        self.validity[5] = false
                    }
                }
                self.barButtonShouldBeEnabled()
                return self.validity[5]
            })
        default:
            return cellForDefault(tableView: tableView, indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func createEntityWithDefaultValues() -> GeoLocationType {
        let newEntity = GeoLocationType()
        newEntity.id = defaultValueFor(GeoLocationType.id)
        return newEntity
    }

    // Check if all text fields are valid
    private func barButtonShouldBeEnabled() {
        let anyFieldInvalid = self.validity.first { (field) -> Bool in
            return field == false
        }
        self.rightBarButton.isEnabled = anyFieldInvalid == nil
    }
}
