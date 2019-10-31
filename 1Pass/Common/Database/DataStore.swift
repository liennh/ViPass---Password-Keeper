//
//  DataStore.swift
//  ViPass
//
//  Created by Ngo Lien on 6/8/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

// https://github.com/ShengHuaWu/RealmMigration

// All changes to an object (addition, modification and deletion) must be done within a write transaction.
@objc final class DataStore:NSObject {
    // MARK: - Properties
    static let currentSchemaVersion: UInt64 = 3
    
    // MARK: - Static Methods
    /*static func seedPeople() throws {
        let tom = Person()
        tom.firstName = "Tom"
        tom.lastName = "Cruise"
        tom.age = 54
        
        let bruno = Person()
        bruno.firstName = "Bruno"
        bruno.lastName = "Mars"
        bruno.age = 31
        
        let taylor = Person()
        taylor.firstName = "Taylor"
        taylor.lastName = "Swift"
        taylor.age = 27
        
        let realm = try Realm()
        try realm.write {
            realm.add([tom, bruno, taylor])
        }
    }*/
    
    static func findAll<T: Object>() throws -> Results<T> {
        let realm = try Realm()
        return realm.objects(T.self)
    }
    
    @objc static func configureMigration() {
        let currentUser = Global.shared.currentUser
        // Generate a random encryption key 64 bytes in length
        let keyBytes = (currentUser?.accountKey)!
        var bytes = [UInt8]()
        bytes.append(contentsOf: keyBytes)
        bytes.append(contentsOf: keyBytes)
        let key = Data(bytes: bytes)
        let username = (currentUser!.username)!
       
        let url = Realm.Configuration.defaultConfiguration.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
        
        let config = Realm.Configuration(fileURL: url, encryptionKey: key, schemaVersion: currentSchemaVersion, migrationBlock: { (migration, oldSchemaVersion) in
           /* if oldSchemaVersion < 1 {
                migrateFrom0To1(with: migration)
            }
            
            if oldSchemaVersion < 2 {
                migrateFrom1To2(with: migration)
            }
            
            if oldSchemaVersion < 3 {
                migrateFrom2To3(with: migration)
            }*/
        })
        
        // Use the default directory, but replace the filename with the username
       // config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(currentUser.username).realm")
        
        Realm.Configuration.defaultConfiguration = config
        DDLog("Path to Database: \(Realm.Configuration.defaultConfiguration.fileURL)")
    }
    
    // MARK: - Migrations
   /* static func migrateFrom0To1(with migration: Migration) {
        // Add an email property
        migration.enumerateObjects(ofType: Person.className()) { (_, newPerson) in
            newPerson?["email"] = ""
        }
    }
    
    static func migrateFrom1To2(with migration: Migration) {
        // Rename name to fullname
        migration.renameProperty(onType: Person.className(), from: "name", to: "fullName")
    }
    
    static func migrateFrom2To3(with migration: Migration) {
        // Replace fullname with firstName and lastName
        migration.enumerateObjects(ofType: Person.className()) { (oldPerson, newPerson) in
            guard let fullname = oldPerson?["fullName"] as? String else {
                fatalError("fullName is not a string")
            }
            
            let nameComponents = fullname.components(separatedBy: " ")
            if nameComponents.count == 2 {
                newPerson?["firstName"] = nameComponents.first
                newPerson?["lastName"] = nameComponents.last
            } else {
                newPerson?["firstName"] = fullname
            }
        }
    }*/
}

