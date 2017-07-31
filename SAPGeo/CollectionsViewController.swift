//
// CollectionsViewController.swift
// SAPGeo
//
// Created by SAP Cloud Platform SDK for iOS Assistant application on 14/06/17
//

import Foundation
import SAPFiori

class CollectionsViewController: UITableViewController, Notifier {

    private var collections = [String]()

    // Variable to store the selected index path
    private var selectedIndex: IndexPath?

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collections = CollectionType.allValues
        self.preferredContentSize = CGSize(width: 320, height: 480)

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
    }

    override func viewDidAppear(_ animated: Bool) {
        self.makeSelection()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.makeSelection()
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> FUISimplePropertyFormCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FUISimplePropertyFormCell.reuseIdentifier, for: indexPath) as! FUISimplePropertyFormCell
        cell.keyName = self.collections[indexPath.row]
        cell.valueTextField.isHidden = true

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMaster" {
            if let selectedRow = self.tableView.indexPathForSelectedRow?.row {
                let master = (segue.destination as! UINavigationController).viewControllers[0] as! MasterViewController
                master.collectionType = CollectionType(rawValue: collections[selectedRow])!
            }
        }
    }

    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
    }

    private func makeSelection() {
        if selectedIndex == nil {
            self.selectDefault()
        } else {
            self.tableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .middle)
        }
    }

    private func selectDefault() {
        // automatically select first element if we have two panels (iPhone plus and iPad only)
        if self.splitViewController!.isCollapsed || self.appDelegate.sapGeoService == nil {
            return
        }
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        self.performSegue(withIdentifier: "showMaster", sender: indexPath)
    }
}
