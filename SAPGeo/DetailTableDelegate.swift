//
// DetailTableDelegate.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import SAPOData
import SAPFiori

protocol DetailTableDelegate: UITableViewDelegate, UITableViewDataSource {
    var entity: EntityValue { get set }
}

extension DetailTableDelegate {

    func cellForProperty(tableView: UITableView, indexPath: IndexPath, property: Property, value: String, changeHandler: @escaping((String) -> Bool)) -> UITableViewCell {
        let cell: UITableViewCell!

        if property.dataType.isBasic {
            // The property is a key or we are creating new entity
            if (!property.isKey || self.entity.isNew) {
                // .. that CAN be edited
                cell = self.cellWithEditableContent(tableView: tableView, indexPath: indexPath, property: property, with: value, changeHandler: changeHandler)
            } else {
                // .. that CANNOT be edited
                cell = self.cellWithNonEditableContent(tableView: tableView, indexPath: indexPath, for: property.name, with: value)
            }
        } else {
            // A complex property
            cell = self.cellWithNonEditableContent(tableView: tableView, indexPath: indexPath, for: property.name, with: "...")
        }
        return cell
    }

    func cellForDefault(tableView: UITableView, indexPath: IndexPath) -> FUISimplePropertyFormCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FUISimplePropertyFormCell.reuseIdentifier, for: indexPath) as! FUISimplePropertyFormCell
        cell.textLabel!.text = ""
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.keyName = "default"

        return cell
    }

    private func cellWithEditableContent(tableView: UITableView, indexPath: IndexPath, property: Property, with value: String, changeHandler: @escaping((String) -> Bool)) -> FUISimplePropertyFormCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FUISimplePropertyFormCell.reuseIdentifier, for: indexPath) as! FUISimplePropertyFormCell

        cell.isEditable = true
        cell.keyName = property.name
        cell.value = value

        if !property.isOptional {
            cell.valueTextField!.placeholder = NSLocalizedString("keyRequiredPlaceholder", value: "Required", comment: "XSEL: Placeholder text for required but currently empty textfield.")
        }

        cell.onChangeHandler = { (newValue) -> Void in
            if !changeHandler(newValue) {
                cell.valueTextField.textColor = UIColor.red
            } else {
                cell.valueTextField.textColor = UIColor.gray
            }
        }

        return cell
    }

    private func cellWithNonEditableContent(tableView: UITableView, indexPath: IndexPath, for key: String, with value: String) -> FUISimplePropertyFormCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FUISimplePropertyFormCell.reuseIdentifier, for: indexPath) as! FUISimplePropertyFormCell

        cell.keyName = key
        cell.value = value

        return cell
    }

    private func selectKeyboardFor(_ type: DataType) -> UIKeyboardType {
        switch type.code {
        case DataType.byte, DataType.short, DataType.integer, DataType.int:
            return .decimalPad
        case DataType.decimal, DataType.double, DataType.localDateTime, DataType.globalDateTime:
            return .numbersAndPunctuation
        default:
            return .`default`
        }
    }

    func defaultValueFor(_ property: Property) -> Double {
        if let defaultValue = property.defaultValue {
            return Double(defaultValue.toString())!
        } else {
            return Double()
        }
    }

    func defaultValueFor(_ property: Property) -> BigDecimal {
        if let defaultValue = property.defaultValue {
            return (defaultValue as! DecimalValue).value
        } else {
            return BigDecimal.fromDouble(Double())
        }
    }

    func defaultValueFor(_ property: Property) -> Int {
        if let defaultValue = property.defaultValue {
            return Int(defaultValue.toString())!
        } else {
            return Int()
        }
    }

    func defaultValueFor(_ property: Property) -> BigInteger {
        if let defaultValue = property.defaultValue {
            return BigInteger(defaultValue.toString())
        } else {
            return BigInteger.fromInt(Int())
        }
    }

    func defaultValueFor(_ property: Property) -> Int64 {
        if let defaultValue = property.defaultValue {
            return Int64(defaultValue.toString())!
        } else {
            return Int64()
        }
    }

    func defaultValueFor(_ property: Property) -> Float {
        if let defaultValue = property.defaultValue {
            return Float(defaultValue.toString())!
        } else {
            return Float()
        }
    }

    func defaultValueFor(_ property: Property) -> LocalDateTime {
        if let defaultValue = property.defaultValue {
            return LocalDateTime.parse(defaultValue.toString())!
        } else {
            return LocalDateTime.now()
        }
    }

    func defaultValueFor(_ property: Property) -> GlobalDateTime {
        if let defaultValue = property.defaultValue {
            return GlobalDateTime.parse(defaultValue.toString())!
        } else {
            return GlobalDateTime.now()
        }
    }

    func defaultValueFor(_ property: Property) -> GuidValue {
        if let defaultValue = property.defaultValue {
            return GuidValue.parse(defaultValue.toString())!
        } else {
            return GuidValue.random()
        }
    }

    func defaultValueFor(_ property: Property) -> String {
        if let defaultValue = property.defaultValue {
            return defaultValue.toString()
        } else {
            return ""
        }
    }

    func defaultValueFor(_ property: Property) -> Bool {
        if let defaultValue = property.defaultValue {
            return defaultValue.toString().toBool()!
        } else {
            return Bool()
        }
    }
}

extension DetailViewController {

    func generatedTableDelegate() -> DetailTableDelegate? {
        switch self.collectionType {
        case .geoLocation:
            return GeoLocationTypeDetailTableDelegate(dataAccess: self.sapGeoService, rightBarButton: self.navigationItem.rightBarButtonItem!)
        default:
            return nil
        }
    }
}
