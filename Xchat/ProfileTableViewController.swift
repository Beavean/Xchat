//
//  ProfileTableViewController.swift
//  Xchat
//
//  Created by Beavean on 15.11.2022.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: - Properties
    
    var user: User?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupUI()
    }
    
    //MARK: - TableView delegates
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "TableViewBackgroundColor")
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            print("DEBUG: Start chat with \(String(describing: user))")
        }
    }
    
    //MARK: - Configuration
    
    private func configureTableView() {
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
    }
    
    private func setupUI() {
        if let user {
            self.title = user.username
            usernameLabel.text = user.username
            statusLabel.text = user.status
            if !user.avatarLink.isEmpty {
                FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
}
