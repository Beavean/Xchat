//
//  SettingsTableViewController.swift
//  Xchat
//
//  Created by Beavean on 10.11.2022.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var applicationVersionLabel: UILabel!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    //MARK: - IBActions
    
    @IBAction func tellFriendButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func termsAndConditionsButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        
    }
    
    //MARK: - Configuration
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        applicationVersionLabel.text = "Version \(appVersion ?? "1.0")"
    }
    
    private func showUserInfo() {
        if let user = User.currentUser {
            usernameLabel.text = user.username
            statusLabel.text = user.status
            if !user.avatarLink.isEmpty {
                
            }
        }
    }
}
