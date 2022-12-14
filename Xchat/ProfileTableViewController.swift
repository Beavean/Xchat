//
//  ProfileTableViewController.swift
//  Xchat
//
//  Created by Beavean on 15.11.2022.
//

import UIKit

final class ProfileTableViewController: UITableViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!

    // MARK: - Properties

    var user: User?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupUI()
    }

    // MARK: - TableView delegates

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
            guard let currentUser = User.currentUser, let receiverUser = user else { return }
            let chatId = startChat(user1: currentUser, user2: receiverUser)
            let privateChatVC = ChatViewController(chatId: chatId, recipientId: receiverUser.id, recipientName: receiverUser.username)
            privateChatVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(privateChatVC, animated: true)
        }
    }

    // MARK: - Configuration

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
