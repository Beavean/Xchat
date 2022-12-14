//
//  OutgoingMessage.swift
//  Xchat
//
//  Created by Beavean on 23.11.2022.
//

import UIKit
import FirebaseFirestoreSwift
import Gallery

final class OutgoingMessage {

    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = Constants.sentMessageStatus
        if let text {
            sendTextMessage(message: message, text: text, memberIds: memberIds)
        }
        if let photo {
            sendPictureMessage(message: message, photo: photo, memberIds: memberIds)
        }
        if let video {
            sendVideoMessage(message: message, video: video, memberIds: memberIds)
        }
        if location != nil {
            sendLocationMessage(message: message, memberIds: memberIds)
        }
        if let audio {
            sendAudioMessage(message: message, audioFileName: audio, audioDuration: audioDuration, memberIds: memberIds)
        }
        PushNotificationService.shared.sendPushNotificationTo(userIds: removeCurrentUserFrom(userIds: memberIds), body: message.message, chatRoomId: chatId)
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
    }

    class func sendChannel(channel: Channel, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?) {
        let currentUser = User.currentUser!
        var channel = channel
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = channel.id
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = Constants.sentMessageStatus
        if let text {
            sendTextMessage(message: message, text: text, memberIds: channel.memberIds, channel: channel)
        }
        if let photo {
            sendPictureMessage(message: message, photo: photo, memberIds: channel.memberIds, channel: channel)
        }
        if let video {
            sendVideoMessage(message: message, video: video, memberIds: channel.memberIds, channel: channel)
        }
        if location != nil {
            sendLocationMessage(message: message, memberIds: channel.memberIds, channel: channel)
        }
        if let audio {
            sendAudioMessage(message: message, audioFileName: audio, audioDuration: audioDuration, memberIds: channel.memberIds, channel: channel)
        }
        PushNotificationService.shared.sendPushNotificationTo(userIds: removeCurrentUserFrom(userIds: channel.memberIds), body: message.message, channel: channel, chatRoomId: channel.id)
        channel.lastMessageDate = Date()
        FirebaseChannelListener.shared.saveChannel(channel)
    }

    class func sendMessage(message: LocalMessage, memberIds: [String]) {
        RealmManager.shared.saveToRealm(message)
        for memberId in memberIds {
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }

    class func sendChannelMessage(message: LocalMessage, channel: Channel) {
        RealmManager.shared.saveToRealm(message)
        FirebaseMessageListener.shared.addChannelMessage(message, channel: channel)
    }
}

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String], channel: Channel? = nil) {
    message.message = text
    message.type = Constants.textMessageType
    if let channel {
        OutgoingMessage.sendChannelMessage(message: message, channel: channel)
    } else {
        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    }
}

func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String], channel: Channel? = nil) {
    message.message = "Picture Message"
    message.type = Constants.photoMessageType
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
    FileStorage.uploadImage(photo, directory: fileDirectory) { imageURL in
        if let imageURL {
            message.pictureUrl = imageURL
            if let channel {
                OutgoingMessage.sendChannelMessage(message: message, channel: channel)
            } else {
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
}

func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String], channel: Channel? = nil) {
    message.message = "Video Message"
    message.type = Constants.videoMessageType
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    let editor = VideoEditor()
    editor.process(video: video) { _, videoUrl in
        if let tempPath = videoUrl {
            let thumbnail = videoThumbnail(video: tempPath)
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory) { imageLink in
                if imageLink != nil {
                    guard let videoData = NSData(contentsOfFile: tempPath.path) else { return }
                    FileStorage.saveFileLocally(fileData: videoData, fileName: fileName + ".mov")
                    FileStorage.uploadVideo(videoData, directory: videoDirectory) { videoLink in
                        message.pictureUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        if let channel {
                            OutgoingMessage.sendChannelMessage(message: message, channel: channel)
                        } else {
                            OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
                        }
                    }
                }
            }
        }
    }
}

func sendLocationMessage(message: LocalMessage, memberIds: [String], channel: Channel? = nil) {
    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location message"
    message.type = Constants.locationMessageType
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    if let channel {
        OutgoingMessage.sendChannelMessage(message: message, channel: channel)
    } else {
        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    }
}

func sendAudioMessage(message: LocalMessage, audioFileName: String, audioDuration: Float, memberIds: [String], channel: Channel? = nil) {
    message.message = "Audio message"
    message.type = Constants.audioMessageType
    let fileDirectory =  "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_\(audioFileName)" + ".m4a"
    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { audioUrl in
        if audioUrl != nil {
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)
            if let channel {
                OutgoingMessage.sendChannelMessage(message: message, channel: channel)
            } else {
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
}
