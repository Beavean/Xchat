//
//  FirebaseMessageListener.swift
//  Xchat
//
//  Created by Beavean on 25.11.2022.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class FirebaseMessageListener {
    
    static let shared = FirebaseMessageListener()
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!
    
    private init() { }
    
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        newChatListener = FirebaseReference(.Messages).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            for change in snapshot.documentChanges {
                if change.type == .added {
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
            }
        })
    }
    
    func checkForOldChats(_ documentId: String, collectionId: String) {
        FirebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { querySnapshot, error in
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
    
    //MARK: - Add, update and delete
    
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        }
        catch {
            print("error saving message ", error.localizedDescription)
        }
    }
    
    func removeListener() {
        newChatListener.remove()
        if self.updatedChatListener != nil {
            self.updatedChatListener.remove()
        }
    }
}
