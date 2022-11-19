//
//  StartChat.swift
//  Xchat
//
//  Created by Beavean on 18.11.2022.
//

import Foundation
import FirebaseFirestore

//MARK: - Start chat

func startChat(user1: User, user2: User) -> String {
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    return chatRoomId
}

func createRecentItems(chatRoomId: String, users: [User]) {
    guard let firstUser = users.first?.id, let secondUser = users.last?.id else { return }
    var memberIdsToCreateRecent = [firstUser, secondUser]
    print("DEBUG: Members to create recent - \(memberIdsToCreateRecent)")
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { snapshot, error in
        guard let snapshot else { return }
        if !snapshot.isEmpty {
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
            print("DEBUG: Updated members to create recent - \(memberIdsToCreateRecent)")
        }
        for userId in memberIdsToCreateRecent {
            print("DEBUG: Creating recent for user with id -  \(userId)")
            let senderUser = userId == User.currentId ? User.currentUser! : getReceiverFrom(users: users)
            let receiverUser = userId == User.currentId ? getReceiverFrom(users: users) : User.currentUser!
            let recentObject = RecentChat(id: UUID().uuidString,
                                          chatRoomId: chatRoomId,
                                          senderId: senderUser.id,
                                          senderName: senderUser.username,
                                          receiverId: receiverUser.id,
                                          receiverName: receiverUser.username,
                                          memberIds: [senderUser.id, receiverUser.id],
                                          lastMessage: "",
                                          unreadCounter: 0,
                                          avatarLink: receiverUser.avatarLink,
                                          date: Date())
            FirebaseRecentListener.shared.saveRecent(recentObject)
        }
    }
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    var memberIdsToCreateRecent = memberIds
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        if let currentUserId = currentRecent[kSENDERID] as? String {
            if memberIdsToCreateRecent.contains(currentUserId), let indexToRemove = memberIdsToCreateRecent.firstIndex(of: currentUserId) {
                memberIdsToCreateRecent.remove(at: indexToRemove)
            }
        }
    }
    return memberIdsToCreateRecent
}

func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    var chatRoomId = ""
    let value = user1Id.compare(user2Id).rawValue
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    return chatRoomId
}

func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}
