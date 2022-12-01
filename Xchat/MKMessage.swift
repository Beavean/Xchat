//
//  MKMessage.swift
//  Xchat
//
//  Created by Beavean on 22.11.2022.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKit.MessageKind
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: MessageKit.SenderType { return mkSender }
    var senderInitials: String
    var status: String
    var readDate: Date
    var photoItem: PhotoMessage?
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
        
        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
        case kPHOTO:
            let photoItem = PhotoMessage(path: message.pictureUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
        default:
            print("DEBUG: Unknown message type")
        }
    }
}
