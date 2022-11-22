//
//  ChatViewController.swift
//  Xchat
//
//  Created by Beavean on 19.11.2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {
    
    //MARK: - UI elements
    
    private let refreshController = UIRefreshControl()
    private let microphoneButton = InputBarButtonItem()
    
    //MARK: - Properties
    
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    let currentUser = MKSEnder(senderId: User.currentId, displayName: User.currentUser?.username ?? "No username")
    
    //MARK: - Inits
    
    init(chatId: String, recipientId: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    //MARK: - Configuration
    
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus")
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            print("DEBUG: Attach button pressed")
        }
        microphoneButton.image = UIImage(systemName: "mic.fill")
        microphoneButton.setSize(CGSize(width: 30, height: 30), animated: false)
        // FIXME: - Add gesture recogniser
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
}
