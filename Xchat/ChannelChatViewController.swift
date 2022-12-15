//
//  ChannelChatViewController.swift
//  Xchat
//
//  Created by Beavean on 10.12.2022.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChannelChatViewController: MessagesViewController {

    // MARK: - UI elements

    private lazy var leftBarButtonView: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()

    private let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()

    private let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()

    private let refreshController = UIRefreshControl()
    private let microphoneButton = InputBarButtonItem()

    // MARK: - Properties

    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    var channel: Channel!
    var mkMessages = [MKMessage]()
    var allLocalMessages: Results<LocalMessage>!
    var gallery: GalleryController!
    let realm = try! Realm()
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser?.username ?? "No username")

    // MARK: - Listeners

    private var notificationToken: NotificationToken?
    private var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName = String()
    var audioDuration: Date!

    // MARK: - Inits

    init(channel: Channel) {
        super.init(nibName: nil, bundle: nil)
        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        self.channel = channel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        configureLeftBarButton()
        configureCustomTitle()
        configureMessageCollectionView()
        configureGestureRecognizer()
        configureMessageInputBar()
        loadChats()
        listenForNewChats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        audioController.stopAnyOngoingPlaying()
    }

    // MARK: - Configurations

    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
    }

    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
    }

    private func configureMessageInputBar() {
        messageInputBar.isHidden = channel.adminId != User.currentId
        messageInputBar.delegate = self
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside {
            _ in
            self.actionAttachMessage()
        }

        microphoneButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        microphoneButton.setSize(CGSize(width: 30, height: 30), animated: false)
        microphoneButton.addGestureRecognizer(longPressGesture)
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        updateMicrophoneButtonStatus(show: true)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }

    func updateMicrophoneButtonStatus(show: Bool) {
        if show {
            messageInputBar.setStackViewItems([microphoneButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }

    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }

    private func configureCustomTitle() {
        self.title = channel.name
    }

    // MARK: - Load Chats

    private func loadChats() {
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            case .update(_, _, let insertions, _):
                for index in insertions {
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                }
            case .error(let error):
                print("Error on new insertion", error.localizedDescription)
            }
        })
    }

    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(chatId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }

    private func checkForOldChats() {
        FirebaseMessageListener.shared.checkForOldChats(chatId, collectionId: chatId)
    }

    // MARK: - Insert Messages

    private func insertMessages() {
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for index in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[index])
        }
    }

    private func insertMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }

    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for index in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessages[index])
        }
    }

    private func insertOlderMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
    }

    // MARK: - Actions

    @objc func backButtonPressed() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }

    func sendMessage(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        OutgoingMessage.sendChannel(channel: channel, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location)
    }

    private func actionAttachMessage() {
        messageInputBar.inputTextView.resignFirstResponder()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.showImageGallery(camera: true)
        }
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (_) in
            self.showImageGallery(camera: false)
        }
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (_) in
            if let _ = LocationManager.shared.currentLocation {
                self.sendMessage(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            } else {
                print("no access to location")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

    // MARK: - UIScrollViewDelegate

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayingMessagesCount < allLocalMessages.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
    }

    // MARK: - Helpers

    private func removeListeners() {
        FirebaseMessageListener.shared.removeListener()
    }

    private func lastMessageDate() -> Date {

        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }

    // MARK: - Gallery

    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        self.present(gallery, animated: true, completion: nil)
    }

    // MARK: - AudioMessages

    @objc func recordAudio() {
        switch longPressGesture.state {
        case .began:
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            AudioRecorder.shared.finishRecording()
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())
                sendMessage(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
            } else {
                print("no audio file")
            }
            audioFileName = ""
        case .possible:
            fallthrough
        case .changed:
            fallthrough
        case .cancelled:
            fallthrough
        case .failed:
            fallthrough
        @unknown default:
            print("Undefined action")
        }
    }
}

extension ChannelChatViewController: GalleryControllerDelegate {

    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first!.resolve { (image) in
                self.sendMessage(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        self.sendMessage(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
