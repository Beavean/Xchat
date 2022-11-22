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
    var mkSender: MKSEnder
    var sender: MessageKit.SenderType { return mkSender }
    var senderInitials: String
    var status: String
    var readDate: Date
    
    init(message)
    
}
