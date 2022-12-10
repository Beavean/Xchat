//
//  ChannelChatViewController.swift
//  Xchat
//
//  Created by Beavean on 10.12.2022.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChannelChatViewController: MessagesViewController {
    
    //MARK: - Properties
    
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    var channel: Channel!
    
    //MARK: - Inits
    
    init(channel: Channel) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        self.channel = channel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
