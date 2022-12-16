//
//  StatusTableViewController.swift
//  Xchat
//
//  Created by Beavean on 12.11.2022.
//

import UIKit

final class StatusTableViewController: UITableViewController {

    // MARK: - Properties

    var allStatuses = [String]() {
        didSet { tableView.reloadData() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadUserStatus()
    }

    // MARK: - Table View Datasource and Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allStatuses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath)
        let status = allStatuses[indexPath.row]
        cell.textLabel?.text = status
        cell.accessoryType = User.currentUser?.status == status ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        updateCellCheck(indexPath)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "TableViewBackgroundColor")
        return headerView
    }

    // MARK: - Status load and update

    private func loadUserStatus() {
        allStatuses = Constants.userDefaults.object(forKey: Constants.status) as? [String] ?? ["No statuses"]
    }

    private func updateCellCheck(_ indexPath: IndexPath) {
        if var user = User.currentUser {
            user.status = allStatuses[indexPath.row]
            saveUserLocally(user)
            FirebaseUserListener.shared.saveUserToFirestore(user)
        }
    }
}
