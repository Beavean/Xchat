//
//  FirebaseTypingListener.swift
//  Xchat
//
//  Created by Beavean on 28.11.2022.
//

import Foundation
import FirebaseFirestore

final class FirebaseTypingListener {

    static let shared = FirebaseTypingListener()

    var typingListener: ListenerRegistration!

    private init() { }

    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        typingListener = firebaseReference(.typing).document(chatRoomId).addSnapshotListener({ snapshot, _ in
            guard let snapshot = snapshot else { return }
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != User.currentId, let dataValue = data.value as? Bool {
                        completion(dataValue)
                    }
                }
            } else {
                completion(false)
                firebaseReference(.typing).document(chatRoomId).setData([User.currentId: false])
            }
        })
    }

    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        firebaseReference(.typing).document(chatRoomId).updateData([User.currentId: typing])
    }

    func removeTypingListener() {
        self.typingListener.remove()
    }
}
