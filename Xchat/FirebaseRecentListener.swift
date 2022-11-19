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
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { querySnapshot, error in
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
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { [weak self] querySnapshot, error in
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
    
    func clearUnreadCounter(recent: RecentChat) {
        var newRecent = recent
        newRecent.unreadCounter = 0
        saveRecent(newRecent)
    }
    
    func saveRecent(_ recent: RecentChat) {
        do {
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch {
            print("DEBUG: Error saving recent chat - \(error.localizedDescription)")
        }
    }
    
    func deleteRecentChat(_ recent: RecentChat) {
        FirebaseReference(.Recent).document(recent.id).delete()
    }
}
