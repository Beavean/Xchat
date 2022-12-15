//
//  SettingsTableViewController.swift
//  Xchat
//
//  Created by Beavean on 10.11.2022.
//

import UIKit
import ProgressHUD

class SettingsTableViewController: UITableViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var applicationVersionLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }

    // MARK: - TableView Delegates

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "TableViewBackgroundColor")
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0.0 : 10.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "SettingsToEditProfileSegue", sender: self)
        }
    }

    // MARK: - IBActions

    @IBAction func tellFriendButtonPressed(_ sender: UIButton) {

    }

    @IBAction func termsAndConditionsButtonPressed(_ sender: UIButton) {

    }

    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        FirebaseUserListener.shared.logOutCurrentUser { [weak self] error in
            if let error {
                ProgressHUD.showFailed(error.localizedDescription)
            } else {
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self?.present(loginView, animated: true)
                }
            }
        }
    }

    // MARK: - Configuration

    private func configureTableView() {
        tableView.tableFooterView = UIView()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        applicationVersionLabel.text = "Version \(appVersion ?? "1.0")"
    }

    // MARK: - UI update

    private func showUserInfo() {
        if let user = User.currentUser {
            usernameLabel.text = user.username
            statusLabel.text = user.status
            if !user.avatarLink.isEmpty {
                FileStorage.downloadImage(imageUrl: user.avatarLink) { [weak self] avatarImage in
                    self?.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
}
