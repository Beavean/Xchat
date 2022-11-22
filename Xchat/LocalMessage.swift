//
//  LocalMessage.swift
//  Xchat
//
//  Created by Beavean on 22.11.2022.
//

import Foundation
import RealmSwift

class LocalMessage: Object, Codable {
    
    @Persisted var id = ""
    @Persisted var chatRoomId = ""
    @Persisted var date = Date()
    @Persisted var senderName = ""
    @Persisted var senderId = ""
    @Persisted var senderinitials = ""
    @Persisted var readDate = Date()
    @Persisted var type = ""
    @Persisted var status = ""
    @Persisted var message = ""
    @Persisted var audioUrl = ""
    @Persisted var videoUrl = ""
    @Persisted var pictureUrl = ""
    @Persisted var latitude = 0.0
    @Persisted var longitude = 0.0
    @Persisted var audioDuration = 0.0

    override class func primaryKey() -> String? {
        return "id"
    }
}
