//
//  FirebaseUserListener.swift
//  Xchat
//
//  Created by Beavean on 08.11.2022.
//

import Foundation
import FirebaseAuth

final class FirebaseUserListener {
    
    static let shard = FirebaseUserListener()
    
    private init() {}
    
    //MARK: - Login
    
    //MARK: - Register
    
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            completion(error)
            if error == nil {
                authDataResult!.user.sendEmailVerification { error in
                    print("DEBUG: Authentication email sent with error: \(String(describing: error?.localizedDescription))")
                }
                if let authDataResult {
                    let user = User(id: authDataResult.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "I'm using Xchat")
                }
            }
        }
    }
}
