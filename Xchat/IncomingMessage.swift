//
//  IncomingMessage.swift
//  Xchat
//
//  Created by Beavean on 25.11.2022.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {
    
    var messageCollectionView: MessagesViewController
    
    init(collectionView: MessagesViewController) {
        messageCollectionView = collectionView
    }
    
    //MARK: - Create message
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(message: localMessage)
        // FIXME: - Multimedia options
        return mkMessage
    }

}
