//
//  RealmManager.swift
//  Xchat
//
//  Created by Beavean on 23.11.2022.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    private let realm = try! Realm()
    
    private init() { }
    
    func saveToRealm<T: Object>(_ object: T) {
        do {
            try realm.write({
                realm.add(object, update: .all)
            })
        } catch {
            print("DEBUG: Error saving realm Object - \(error.localizedDescription)")
        }
    }
}
