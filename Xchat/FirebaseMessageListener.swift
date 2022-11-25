//
//  FirebaseMessageListener.swift
//  Xchat
//
//  Created by Beavean on 25.11.2022.
//

import Foundation
import FirebaseFirestoreSwift

class FirebaseMessageListener {
    
    static let shared = FirebaseMessageListener()
    
    private init() { }
    
    //MARK: - Add, update and delete
    
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            try FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        }
        catch {
            print("error saving message ", error.localizedDescription)
        }
    }
}
