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
    var mkMessages = [MKMessage]()
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    //MARK: - Properties
    
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser?.username ?? "No username")
    
    //MARK: - Listeners
    
    private var notificationToken: NotificationToken?
    
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
        configureMessageInputBar()
        configureMessageCollectionView()
        loadChats()
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
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            print("DEBUG: Attach button pressed")
        }
        microphoneButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        microphoneButton.setSize(CGSize(width: 30, height: 30), animated: false)
        // FIXME: - Add gesture recogniser
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    //MARK: - Load chats
    
    private func loadChats() {
        let predicate = NSPredicate(format: "\(kCHATROOMID) = %@", chatId)
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        notificationToken = allLocalMessages.observe({ [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self?.insertMessages()
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            case .update(_, _ , let insertions, _):
                for index in insertions {
                    guard let allLocalMessages = self?.allLocalMessages else { return }
                    self?.insertMessage(allLocalMessages[index])
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem(animated: false)
                }
            case .error(let error):
                print("Error on new insertion", error.localizedDescription)
            }
        })
    }
    
    private func insertMessages() {
        for message in allLocalMessages {
            insertMessage(message)
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(collectionView: self)
        guard let message = incoming.createMessage(localMessage: localMessage) else { return }
        self.mkMessages.append(message)
    }
    
    
    //MARK: - Actions
    
    func sendMessage(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recipientId])
    }
}
