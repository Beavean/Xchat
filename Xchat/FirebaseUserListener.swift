//
//  FirebaseUserListener.swift
//  Xchat
//
//  Created by Beavean on 08.11.2022.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init() {}
    
    //MARK: - Login user
    
    func loginUserWithEmail(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if let authDataResult, authDataResult.user.isEmailVerified && error == nil {
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult.user.uid, email: email)
                completion(error, true)
                
            } else {
                print("DEBUG: Email is not verified")
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register user
    
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authDataResult, error in
            completion(error)
            if error == nil {
                authDataResult!.user.sendEmailVerification { error in
                    print("DEBUG: Authentication email sent with error: \(String(describing: error?.localizedDescription))")
                }
                if let authDataResult {
                    let user = User(id: authDataResult.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "I'm using Xchat 🤙")
                    saveUserLocally(user)
                    self?.saveUserToFirestore(user)
                }
            }
        }
    }
    
    //MARK: - Resend verification link
    
    func resendVerificationEmail(email: String, completion: @escaping(_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { error in
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                completion(error)
            })
        })
    }
    
    //MARK: - Reset password
    
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    //MARK: - Log Out user
    
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    
    //MARK: - Save user
    
    func saveUserToFirestore(_ user: User) {
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print("DEBUG: Adding user \(error.localizedDescription)")
        }
    }
    
    //MARK: - Download user
    
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        FirebaseReference(.User).document(userId).getDocument { snapshot, error in
            guard let snapshot else {
                print("DEBUG: No document for user")
                return
            }
            let result = Result {
                try? snapshot.data(as: User.self)
            }
            switch result {
            case .success(let user):
                if let user {
                    saveUserLocally(user)
                } else {
                    print("DEBUG: Document doesn't exist")
                }
            case .failure(let error):
                print("DEBUG: Error decoding user \(error.localizedDescription)")
            }
        }
    }
    
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void) {
        var users: [User] = []
        FirebaseReference(.User).limit(to: 20).getDocuments { querySnapshot, error in
            guard let document = querySnapshot?.documents else {
                print("DEBUG: No documents in all users.")
                return
            }
            let allUsers = document.compactMap { queryDocumentSnapshot -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            for user in allUsers {
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            completion(users)
        }
    }
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        var count = 0
        var usersArray = [User]()
        for userId in withIds {
            FirebaseReference(.User).document(userId).getDocument { querySnapshot, error in
                guard let document = querySnapshot else {
                    print("DEBUG: No documents in all users.")
                    return
                }
                let user = try? document.data(as: User.self)
                usersArray.append(user!)
                count += 1
                if count == withIds.count {
                    completion(usersArray)
                }
            }
        }
    }
}
