//
// DetailViewController.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import SAPFoundation
import SAPOData
import SAPFiori
import SAPCommon

class DetailViewController: UITableViewController, Notifier, LoadingIndicator {

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    private var tableDelegate: DetailTableDelegate!
    var tableUpdater: TableUpdaterDelegate?
    var loadingIndicator: FUILoadingIndicatorView?

    private let logger = Logger.shared(named: "DetailViewControllerLogger")
    var sapGeoService: SAPGeoServiceDataAccess {
        return appDelegate.sapGeoService
    }

    // The Entity which will be edited on the Detail View
    var selectedEntity: EntityValue!

    var collectionType: CollectionType = .none {
        didSet {
            if let delegate = self.generatedTableDelegate() {
                self.tableDelegate = delegate
                if self.selectedEntity != nil {
                    self.tableDelegate.entity = self.selectedEntity
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.allowsSelection = false
        self.tableView.dataSource = tableDelegate
        self.tableView.delegate = tableDelegate

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
    }

    @IBAction func updateEntity(_ sender: AnyObject) {
        self.showIndicator()
        self.view.endEditing(true)
        self.logger.info("Updating entity in backend.")
        self.sapGeoService.service.updateEntity(self.tableDelegate.entity) { error in
            self.hideIndicator()

            if let error = error {
                self.logger.error("Update entry failed.", error: error)
                self.displayAlert(title: NSLocalizedString("keyErrorEntityUpdateTitle", value: "Update entry failed", comment: "XTIT: Title of alert message about entity update failure."),
                    message: NSLocalizedString("keyErrorEntityUpdateBody", value: error.localizedDescription, comment: "XMSG: Body of alert message about entity update failure."))
                return
            }

            self.logger.info("Update entry finished successfully.")
            FUIToastMessage.show(message: NSLocalizedString("keyUpdateEntityFinishedTitle", value: "Updated", comment: "XTIT: Title of alert message about successful entity update."))
            self.tableUpdater?.updateTable()
        }
    }

    func createEntity() {
        self.showIndicator()
        self.view.endEditing(true)
        self.logger.info("Creating entity in backend.")
        self.sapGeoService.service.createEntity(self.tableDelegate.entity) { error in
            self.hideIndicator()

            if let error = error {
                self.logger.error("Create entry failed.", error: error)
                self.displayAlert(title: NSLocalizedString("keyErrorEntityCreationTitle", value: "Create entry failed", comment: "XTIT: Title of alert message about entity creation error."),
                    message: NSLocalizedString("keyErrorEntityCreationBody", value: error.localizedDescription, comment: "XMSG: Body of alert message about entity creation error."))
                return
            }

            self.logger.info("Create entry finished successfully.")
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    FUIToastMessage.show(message: NSLocalizedString("keyEntityCreationBody", value: "Created", comment: "XMSG: Title of alert message about successful entity creation."))
                    self.tableUpdater?.updateTable()
                }
            }
        }
    }

    func cancel() -> Void {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
