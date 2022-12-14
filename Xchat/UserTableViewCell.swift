//
//  UserTableViewCell.swift
//  Xchat
//
//  Created by Beavean on 14.11.2022.
//

import UIKit

final class UserTableViewCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!

    // MARK: - Lifecycle

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(user: User) {
        usernameLabel.text = user.username
        statusLabel.text = user.status
        setAvatar(avatarLink: user.avatarLink)
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
