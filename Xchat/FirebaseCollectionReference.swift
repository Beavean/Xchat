//
//  FirebaseCollectionReference.swift
//  Xchat
//
//  Created by Beavean on 08.11.2022.
//

import Foundation
import FirebaseFirestore

enum FirebaseCollectionReference: String {
    case user
    case recent
    case messages
    case typing
    case channel
}

func firebaseReference(_ collectionReference: FirebaseCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
