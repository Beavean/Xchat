//
//  ChannelTableViewCell.swift
//  Xchat
//
//  Created by Beavean on 07.12.2022.
//

import UIKit

final class ChannelTableViewCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var aboutLabel: UILabel!
    @IBOutlet private weak var memberCountLabel: UILabel!
    @IBOutlet private weak var lastMessageDateLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Configuration

    func configure(channel: Channel) {
        nameLabel.text = channel.name
        aboutLabel.text = channel.aboutChannel
        memberCountLabel.text = "\(channel.memberIds.count) members"
        lastMessageDateLabel.text = timeElapsed(channel.lastMessageDate ?? Date())
        lastMessageDateLabel.adjustsFontSizeToFitWidth = true
        setAvatar(avatarLink: channel.avatarLink)
    }

    private func setAvatar(avatarLink: String) {
        if !avatarLink.isEmpty {
            FileStorage.downloadImage(imageUrl: avatarLink) { avatarImage in
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(systemName: "person.2.circle")
                }
            }
        } else {
            self.avatarImageView.image = UIImage(systemName: "person.2.circle")
        }
    }
}
