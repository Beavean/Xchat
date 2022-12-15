//
//  InputBarAccessoryViewDelegate.swift
//  Xchat
//
//  Created by Beavean on 22.11.2022.
//

import Foundation
import InputBarAccessoryView

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if !text.isEmpty {
            typingIndicatorUpdate()
        }
        updateMicrophoneButtonStatus(show: text.isEmpty)
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                sendMessage(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}

extension ChannelChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        updateMicrophoneButtonStatus(show: text.isEmpty)
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                sendMessage(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
