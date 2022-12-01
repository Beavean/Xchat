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
        if localMessage.type == kPHOTO {
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { [weak self] image in
                mkMessage.photoItem?.image = image
                self?.messageCollectionView.messagesCollectionView.reloadData()
            }
        }
        return mkMessage
    }
}
