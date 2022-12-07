//
//  ChannelsTableViewController.swift
//  Xchat
//
//  Created by Beavean on 07.12.2022.
//

import UIKit

class ChannelsTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var channelsSegmentedControlOutlet: UISegmentedControl!
    
    //MARK: - Properties
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
    //MARK: - IBActions
    
    @IBAction func channelsSegmentValueChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    //MARK: - Configuration
    
    private func configure() {
        navigationItem.largeTitleDisplayMode = .always
        self.title = "Channels"
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        tableView.tableFooterView = UIView()
    }
}
