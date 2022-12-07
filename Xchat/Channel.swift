//
//  Channel.swift
//  Xchat
//
//  Created by Beavean on 07.12.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Channel: Codable {
    
    var id = ""
    var name = ""
    var adminId = ""
    var memberIds = [""]
    var avatarLink = ""
    var aboutChannel = ""
    @ServerTimestamp var createdDate = Date()
    @ServerTimestamp var lastMessageDate = Date()

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case adminId
        case memberIds
        case avatarLink
        case aboutChannel
        case createdDate
        case lastMessageDate = "date"
    }
}
