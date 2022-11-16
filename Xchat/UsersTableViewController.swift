//
//  UsersTableViewController.swift
//  Xchat
//
//  Created by Beavean on 14.11.2022.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var allUsers: [User] = []
    var filteredUsers: [User] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshController()
        setupSearchController()
        downloadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUsers.count : allUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else { return UITableViewCell() }
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        cell.configure(user: user)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        showUserProfile(user)
    }
    
    //MARK: - Users download
    
    private func downloadUsers() {
        FirebaseUserListener.shared.downloadAllUsersFromFirebase { [weak self] allFirebaseUsers in
            self?.allUsers = allFirebaseUsers
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Refresh config
    
    private func configureRefreshController() {
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
    }
    
    //MARK: - Search setup
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    private func filteredContent(forSearchText searchText: String) {
        filteredUsers = allUsers.filter({ user -> Bool in
            return user.username.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    //MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let refreshControl else { return }
        if refreshControl.isRefreshing {
            downloadUsers()
            refreshControl.endRefreshing()
        }
    }
    
    //MARK: - Navigation
    
    private func showUserProfile(_ user: User) {
        guard let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController else { return }
        profileView.user = user
        self.navigationController?.pushViewController(profileView, animated: true)
    }
}

extension UsersTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContent(forSearchText: searchController.searchBar.text ?? "")
    }
}
