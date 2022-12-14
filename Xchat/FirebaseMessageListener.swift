//
//  FirebaseMessageListener.swift
//  Xchat
//
//  Created by Beavean on 25.11.2022.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

final class FirebaseMessageListener {

    static let shared = FirebaseMessageListener()
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!

    private init() { }

    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        newChatListener = firebaseReference(.messages).document(documentId).collection(collectionId).whereField(Constants.messageDate, isGreaterThan: lastMessageDate).addSnapshotListener({ querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            for change in snapshot.documentChanges where change.type == .added {
                let result = Result {
                    try? change.document.data(as: LocalMessage.self)
                }
                switch result {
                case .success(let messageObject):
                    if let messageObject {
                        if messageObject.senderId != User.currentId {
                            RealmManager.shared.saveToRealm(messageObject)
                        }
                    } else {
                        print("Document doesn't exist")
                    }
                case .failure(let error):
                    print("Error decoding local message: \(error.localizedDescription)")
                }
            }
        })
    }

    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping (_ updatedMessage: LocalMessage) -> Void) {
        updatedChatListener = firebaseReference(.messages).document(documentId).collection(collectionId).addSnapshotListener({ snapshot, error in
            guard let snapshot else { return }
            for change in snapshot.documentChanges where change.type == .modified {
                let result = Result {
                    try? change.document.data(as: LocalMessage.self)
                }
                switch result {
                case .success(let message):
                    if let message {
                        completion(message)
                    } else {
                        print("Document does not exist in chat")
                    }
                case .failure(let error):
                    print("Error decoding local message: \(error)")
                }
            }
        })
    }

    func checkForOldChats(_ documentId: String, collectionId: String) {
        firebaseReference(.messages).document(documentId).collection(collectionId).getDocuments { querySnapshot, _ in
            guard let documents = querySnapshot?.documents else {
                print("no documents for old chats")
                return
            }
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            oldMessages.sort(by: { $0.date < $1.date })
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
            }
        }
    }

    // MARK: - Add, update and delete

    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            try firebaseReference(.messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        } catch {
            print("error saving message ", error.localizedDescription)
        }
    }

    func addChannelMessage(_ message: LocalMessage, channel: Channel) {
        do {
            try firebaseReference(.messages).document(channel.id).collection(channel.id).document(message.id).setData(from: message)
        } catch {
            print("error saving message ", error.localizedDescription)
        }
    }

    // MARK: - Update message status

    func updateMessageInFireStore(_ message: LocalMessage, memberIds: [String]) {
        let values = [Constants.status: Constants.readMessageStatus, Constants.messageReadDate: Date()] as [String: Any]
        for userId in memberIds {
            firebaseReference(.messages).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
        }
    }

    func removeListener() {
        newChatListener.remove()
        if self.updatedChatListener != nil {
            self.updatedChatListener.remove()
        }
    }
}
