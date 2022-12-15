//
//  User.swift
//  Xchat
//
//  Created by Beavean on 08.11.2022.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift

struct User: Codable, Equatable {

    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String

    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }

    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                let decoder = JSONDecoder()
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("DEBUG: Error decoding user from user defaults, \(error.localizedDescription)")
                }
            }
        }
        return nil
    }

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

func saveUserLocally(_ user: User) {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("DEBUG: Error saving User locally, \(error.localizedDescription)")
    }
}
