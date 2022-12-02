//
//  MessageCellDelegate.swift
//  Xchat
//
//  Created by Beavean on 22.11.2022.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if let image = mkMessage.photoItem?.image {
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(image)
                images.append(photo)
                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: nil)
            }
            
            if let videoUrl = mkMessage.videoItem?.url {
                let player = AVPlayer(url: videoUrl)
                let moviePlayer = AVPlayerViewController()
                let session = AVAudioSession.sharedInstance()
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                moviePlayer.player = player
                present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
            }
        }
    }
}
