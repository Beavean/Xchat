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
    
    var allChannels: [Channel] = []
    var subscribedChannels: [Channel] = []
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsSegmentedControlOutlet.selectedSegmentIndex == 0 ? subscribedChannels.count : allChannels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelTableViewCell
        let channel = channelsSegmentedControlOutlet.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]
        cell.configure(channel: channel)
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if channelsSegmentedControlOutlet.selectedSegmentIndex == 1 {
            showChannelView(channel: allChannels[indexPath.row])
        } else {
            showChat(channel: subscribedChannels[indexPath.row])
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if channelsSegmentedControlOutlet.selectedSegmentIndex == 1 {
            return false
        } else {
            return subscribedChannels[indexPath.row].adminId != User.currentId
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var channelToUnfollow = subscribedChannels[indexPath.row]
            subscribedChannels.remove(at: indexPath.row)
            if let index = channelToUnfollow.memberIds.firstIndex(of: User.currentId) {
                channelToUnfollow.memberIds.remove(at: index)
            }
//            FirebaseChannelListener.shared.saveCannel(channelToUnfollow)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
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
    
    //MARK: - Navigation
    
    private func showChannelView(channel: Channel) {
//        let channelVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "channelView") as! ChannelDetailTableViewController
//        channelVC.channel = channel
//        channelVC.delegate = self
//        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    private func showChat(channel: Channel) {
//        let channelChatVC = ChannelChatViewController(channel: channel)
//        channelChatVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(channelChatVC, animated: true)
    }
}
