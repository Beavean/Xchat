//
//  ChatsTableViewController.swift
//  Xchat
//
//  Created by Beavean on 18.11.2022.
//

import UIKit

class ChatsTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var allRecents = [RecentChat]()
    var filteredRecentChats = [RecentChat]()

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        downloadRecentChats()
    }
    
    //MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allRecents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? RecentTableViewCell else { return UITableViewCell() }
        cell.configure(recent: allRecents[indexPath.row])
        return cell
    }
    
    //MARK: - Download chats
    
    private func downloadRecentChats() {
        FirebaseRecentListener.shared.downloadRecentChatsFromFireStore { [weak self] allRecents in
            self?.allRecents = allRecents
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}
