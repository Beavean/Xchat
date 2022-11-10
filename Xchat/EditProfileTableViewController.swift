//
//  EditProfileTableViewController.swift
//  Xchat
//
//  Created by Beavean on 10.11.2022.
//

import UIKit

class EditProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        showUserInfo()
    }
    
    //MARK: - TableView Delegates
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "TableViewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0.0 : 10.0
    }
    
    //MARK: - Configuration
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func showUserInfo() {
        if let user = User.currentUser {
            statusLabel.text = user.status
            if !user.avatarLink.isEmpty {
                
            }
        }
    }
}
