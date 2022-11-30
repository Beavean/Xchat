//
//  RecentTableViewCell.swift
//  Xchat
//
//  Created by Beavean on 17.11.2022.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCounterLabel: UILabel!
    @IBOutlet weak var unreadCounterBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadCounterBackgroundView.layer.cornerRadius = unreadCounterBackgroundView.frame.width / 2
    }
    
    func configure(recent: RecentChat) {
        usernameLabel.text = recent.receiverName
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9
        lastMessageLabel.text = recent.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        lastMessageLabel.minimumScaleFactor = 0.9
        lastMessageLabel.numberOfLines = 2
        if recent.unreadCounter != 0 {
            unreadCounterLabel.text = "\(recent.unreadCounter)"
            unreadCounterBackgroundView.isHidden = false
        } else {
            unreadCounterBackgroundView.isHidden = true
        }
        setAvatar(avatarLink: recent.avatarLink)
        dateLabel.text = timeElapsed(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setAvatar(avatarLink: String) {
        if !avatarLink.isEmpty {
            FileStorage.downloadImage(imageUrl: avatarLink) { [weak self] avatarImage in
                self?.avatarImageView.image = avatarImage?.circleMasked
            }
        } else {
            self.avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
}
