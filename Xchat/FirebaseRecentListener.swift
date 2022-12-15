//
//  FirebaseRecentListener.swift
//  Xchat
//
//  Created by Beavean on 18.11.2022.
//

import Foundation
import FirebaseFirestore

class FirebaseRecentListener {

    static let shared = FirebaseRecentListener()

    private init() {}

    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void) {
        firebaseReference(.recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { querySnapshot, _ in
            var recentChats = [RecentChat]()
            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No documents found for recent chat.")
                return
            }
            let allRecents = documents.compactMap { queryDocumentSnapshot -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            for recent in allRecents {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }
            recentChats.sort(by: { $0.date! > $1.date! })
            completion(recentChats)
        }
    }

    func resetRecentCounter(chatRoomId: String) {
        firebaseReference(.recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { [weak self] querySnapshot, _ in
            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No documents found for recents.")
                return
            }
            let allRecents = documents.compactMap { queryDocumentSnapshot -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            if allRecents.count > 0 {
                self?.clearUnreadCounter(recent: allRecents.first!)
            }
        }
    }

    func updateRecents(chatRoomId: String, lastMessage: String) {
        firebaseReference(.recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { querySnapshot, _ in
            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }
            let allRecents = documents.compactMap { queryDocumentSnapshot -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }

    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
        var tempRecent = recent
        if tempRecent.senderId != User.currentId {
            tempRecent.unreadCounter += 1
        }
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        self.saveRecent(tempRecent)
    }

    func clearUnreadCounter(recent: RecentChat) {
        var newRecent = recent
        newRecent.unreadCounter = 0
        saveRecent(newRecent)
    }

    func saveRecent(_ recent: RecentChat) {
        do {
            try firebaseReference(.recent).document(recent.id).setData(from: recent)
        } catch {
            print("DEBUG: Error saving recent chat - \(error.localizedDescription)")
        }
    }

    func deleteRecentChat(_ recent: RecentChat) {
        firebaseReference(.recent).document(recent.id).delete()
    }
}
