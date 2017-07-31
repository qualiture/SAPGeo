//
// MasterViewController.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import SAPOData
import SAPFoundation
import SAPFiori
import SAPCommon

protocol TableUpdaterDelegate {
    func updateTable()
}

class MasterViewController: UITableViewController, TableUpdaterDelegate, Notifier, LoadingIndicator {

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var tableDelegate: MasterTableDelegate!
    var loadingIndicator: FUILoadingIndicatorView?

    var collectionType: CollectionType = .none {
        didSet {
            self.configureView()
        }
    }

    private let logger = Logger.shared(named: "MasterViewControllerLogger")
    var sapGeoService: SAPGeoServiceDataAccess {
        return appDelegate.sapGeoService
    }

    func refresh() {
        DispatchQueue.global().async {
            self.updateTable() {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // add refreshcontrol UI
        self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl!)

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 98
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            // Show the selected Entity on the Detail view
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.logger.info("Showing details of the chosen element.")
                let selectedEntity = self.tableDelegate.entities[indexPath.row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.selectedEntity = selectedEntity
                detailViewController.collectionType = self.collectionType
                detailViewController.navigationItem.leftItemsSupplementBackButton = true
                detailViewController.tableUpdater = self
            }
        } else if segue.identifier == "addEntity" {
            if self.collectionType != .none {
                // Show the Detail view with a new Entity, which can be filled to create on the server
                self.logger.info("Showing view to add new entity.")
                let dest = segue.destination as! UINavigationController
                let detailViewController = dest.viewControllers[0] as! DetailViewController
                detailViewController.title = NSLocalizedString("keyAddEntityTitle", value: "Add Entity", comment: "XTIT: Title of add new entity screen.")
                let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: detailViewController, action: #selector(detailViewController.createEntity))
                detailViewController.navigationItem.rightBarButtonItem = doneButton
                let cancelButton = UIBarButtonItem(title: NSLocalizedString("keyCancelButtonToGoPreviousScreen", value: "Cancel", comment: "XBUT: Title of Cancel button."),
                    style: .plain, target: detailViewController, action: #selector(detailViewController.cancel))
                detailViewController.navigationItem.leftBarButtonItem = cancelButton
                detailViewController.collectionType = self.collectionType
                detailViewController.showDetailViewController(detailViewController, sender: sender)
                detailViewController.tableUpdater = self
            } else {
                self.displayAlert(title: NSLocalizedString("keyErrorEntityCreationTitle", value: "Entity creation error", comment: "XTIT: Title of alert message about entity creation error."),
                    message: NSLocalizedString("keyErrorEntityCreationBody", value: "Please select the proper collection to create an entity.", comment: "XMSG: Body of alert message about entity creation error."))
            }
        }
    }

    private func configureView() {
        if self.collectionType != .none {
            self.title = collectionType.rawValue
            if let tableDelegate = self.generatedTableDelegate() {
                self.tableDelegate = tableDelegate
                if let tableView = self.tableView {
                    self.tableDelegate.notifier = self
                    tableView.delegate = tableDelegate
                    tableView.dataSource = tableDelegate
                    self.updateTable()
                }
            }
        }
    }

    func updateTable() {
        self.showIndicator()
        DispatchQueue.global().async {
            self.updateTable() {
                self.hideIndicator()
            }
        }
    }

    private func updateTable(completionHandler: @escaping() -> Void) {

        self.tableDelegate?.requestEntities { error in

            defer {
                completionHandler()
            }

            if let error = error {
                self.displayAlert(title: NSLocalizedString("keyErrorLoadingData", value: "Loading data failed!", comment: "XTIT: Title of loading data error pop up."),
                    message: error.localizedDescription)
                self.logger.error("Could not update table.", error: error)
                return
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.logger.info("Table updated successfully!")
            }
        }
    }

    func errorDuringDelete(error: Error) {
        self.displayAlert(title: NSLocalizedString("keyErrorDeletingEntryTitle", value: "Delete entry failed", comment: "XTIT: Title of deleting entry error pop up."),
            message: NSLocalizedString("keyErrorDeletingEntryBody", value: "The operation was unsuccessful.", comment: "XMSG: Body of deleting entry error pop up.") + error.localizedDescription)
    }
}
