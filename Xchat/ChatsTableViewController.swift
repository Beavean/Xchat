//
//  ChatsTableViewController.swift
//  Xchat
//
//  Created by Beavean on 18.11.2022.
//

import UIKit

class ChatsTableViewController: UITableViewController {

    // MARK: - Properties

    var allRecents = [RecentChat]()
    var filteredRecentChats = [RecentChat]()
    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        downloadRecentChats()
        setupSearchController()
    }

    // MARK: - IBActions

    @IBAction func composeBarButtonPressed(_ sender: UIBarButtonItem) {
        guard let userView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersTableViewController") as? UsersTableViewController else { return }
        navigationController?.pushViewController(userView, animated: true)
    }

    // MARK: - TableView data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchController.isActive ? filteredRecentChats.count : allRecents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? RecentTableViewCell else { return UITableViewCell() }
        let recent = searchController.isActive ? filteredRecentChats[indexPath.row] : allRecents[indexPath.row]
        cell.configure(recent: recent)
        return cell
    }

    // MARK: - TableView delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let recent = searchController.isActive ? filteredRecentChats[indexPath.row] : allRecents[indexPath.row]
        FirebaseRecentListener.shared.clearUnreadCounter(recent: recent)
        goToChat(recent: recent)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recent = searchController.isActive ? filteredRecentChats[indexPath.row] : allRecents[indexPath.row]
            FirebaseRecentListener.shared.deleteRecentChat(recent)
            searchController.isActive ? filteredRecentChats.remove(at: indexPath.row) : allRecents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: - Download chats

    private func downloadRecentChats() {
        FirebaseRecentListener.shared.downloadRecentChatsFromFireStore { [weak self] allRecents in
            self?.allRecents = allRecents
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Navigation

    private func goToChat(recent: RecentChat) {
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        let privateChatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName)
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }

    // MARK: - Search Controller

    private func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }

    private func filteredContent(forSearchText searchText: String) {
        filteredRecentChats = allRecents.filter({ recent -> Bool in
            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

extension ChatsTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        filteredContent(forSearchText: searchController.searchBar.text ?? "")
    }
}
