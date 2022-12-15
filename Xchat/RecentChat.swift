//
//  RecentChat.swift
//  Xchat
//
//  Created by Beavean on 16.11.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentChat: Codable {

    var id = ""
    var chatRoomId = ""
    var senderId = ""
    var senderName = ""
    var receiverId = ""
    var receiverName = ""
    var memberIds = [String]()
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    @ServerTimestamp var date = Date()
}
