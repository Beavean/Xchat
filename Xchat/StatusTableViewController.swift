//
//  StatusTableViewController.swift
//  Xchat
//
//  Created by Beavean on 12.11.2022.
//

import UIKit

class StatusTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var allStatuses = [String]() {
        didSet { tableView.reloadData() }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadUserStatus()
    }
    
    //MARK: - Table View Datasource and Delegate
    
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
    
    //MARK: - Configuration
    
    private func loadUserStatus() {
        allStatuses = userDefaults.object(forKey: kSTATUS) as? [String] ?? ["No statuses"]
    }
}
