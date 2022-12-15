//
//  MyChannelsTableViewController.swift
//  Xchat
//
//  Created by Beavean on 08.12.2022.
//

import UIKit

class MyChannelsTableViewController: UITableViewController {

    // MARK: - Properties

    var myChannels = [Channel]()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        downloadUserChannels()
    }

    // MARK: - Download Channels

    private func downloadUserChannels() {
        FirebaseChannelListener.shared.downloadUserChannelsFromFirebase { (allChannels) in
            self.myChannels = allChannels
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - IBActions

    @IBAction func addBarButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "AddChannelSegue", sender: self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myChannels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as? ChannelTableViewCell else { return UITableViewCell() }
        cell.configure(channel: myChannels[indexPath.row])
        return cell
    }

    // MARK: - TableView Delegates

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "AddChannelSegue", sender: myChannels[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let channelToDelete = myChannels[indexPath.row]
            myChannels.remove(at: indexPath.row)
            FirebaseChannelListener.shared.deleteChannel(channelToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddChannelSegue" {
            guard let editChannelView = segue.destination as? AddChannelTableViewController else { return }
            editChannelView.channelToEdit = sender as? Channel
        }
    }
}
