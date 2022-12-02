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
        switch localMessage.type {
        case kPHOTO:
            let photoItem = PhotoMessage(path: localMessage.pictureUrl)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { [weak self] image in
                mkMessage.photoItem?.image = image
                self?.messageCollectionView.messagesCollectionView.reloadData()
            }
        case kVIDEO:
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl) { [weak self] thumbNail in
                FileStorage.downloadVideo(videoLink: localMessage.videoUrl) { (readyToPlay, fileName) in
                    let videoURL = URL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
                    let videoItem = VideoMessage(url: videoURL)
                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }
                mkMessage.videoItem?.image = thumbNail
                self?.messageCollectionView.messagesCollectionView.reloadData()
            }
        case kLOCATION:
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        default:
            break
        }
        return mkMessage
    }
}
