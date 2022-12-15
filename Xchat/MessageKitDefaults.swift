//
//  MessageKitDefaults.swift
//  Xchat
//
//  Created by Beavean on 22.11.2022.
//

import UIKit
import MessageKit

struct MKSender: SenderType, Equatable {

    var senderId: String
    var displayName: String
}

enum MessageDefaults {
    static let outgoingBubbleColor = UIColor(named: "OutgoingChatBubble") ?? .systemGray6
    static let incomingBubbleColor = UIColor(named: "IncomingChatBubble") ?? .systemGray

}
