//
//  Record.swift
//  ViPass
//
//  Created by Ngo Lien on 4/30/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import RealmSwift

public class Record:Object, NSCopying {
    @objc dynamic var id = UUID().uuidString // never changed after set
    // Username
    @objc dynamic var createdBy:String! = Global.shared.currentUser?.username // never changed after set
    
    @objc dynamic var createdAt:Date = Date() // for record
    @objc dynamic var updatedAt:Date = Date() // for record. lastUpdatedLocallyUTC
    @objc dynamic var ts:Date? // for record. Only updated when saved on server successfully
    
    @objc dynamic var title:String! // No encryption, used for search
    @objc dynamic var tags:String? = nil  // No encryption, used for search
    let fields = List<Field>()  // encrypted
   
    @objc dynamic var titleUpdatedAt:Date = Date()
    @objc dynamic var tagsUpdatedAt:Date = Date(timeIntervalSince1970: 1) // optional value
    
    @objc dynamic var isDirty:Bool = false  // Local property
    //  0: not deleted
    // -1: deleted locally. But not synced with server
    //  1: deleted on server
    @objc dynamic var isDeleted:Int = 0
    @objc dynamic var isSynced:Bool = false // Local property. false means just created on local. Not exist on server
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Record()
        copy.id = self.id
        copy.title = self.title
        copy.tags = self.tags
        copy.createdBy = self.createdBy
        copy.createdAt = self.createdAt
        copy.updatedAt = self.updatedAt
        copy.ts = self.ts
        copy.titleUpdatedAt = self.titleUpdatedAt
        copy.tagsUpdatedAt = self.tagsUpdatedAt
        copy.isDirty = self.isDirty
        copy.isDeleted = self.isDeleted
        copy.isSynced = self.isSynced
    
        for item in self.fields {
            let copiedItem = item.copy()
            copy.fields.append(copiedItem as! Field)
        }
        return copy
    }
    
    // Convert into dictionary for sending request to server
    func toDictionary() -> [String:Any] {
        var fields = [[String:Any]]()
        for item in self.fields {
            fields.append(item.toDictionary())
        }
        
        let currentUser = Global.shared.currentUser
        // [UInt8]?
        guard let enc_data = AppEncryptor.encryptAES256(plainData: fields.json.bytes, key: (currentUser?.accountKey)!) else {
            return [:]
        }
        
        var deleted = self.isDeleted
        if self.isDeleted == -1 { // deleted locally. But not synced with server
            deleted = 1 // deleted on server
        }
        
        let dict = [
            "id": self.id,
            "title": self.title,
            "tags": self.tags ?? "",
            "createdBy": self.createdBy,
            "createdAt": self.createdAt.utcString(),
            "updatedAt": self.updatedAt.utcString(),
            "ts": self.ts!.utcString(), // ts cannot nil here
            "titleUpdatedAt": self.titleUpdatedAt.utcString(),
            "tagsUpdatedAt": self.tagsUpdatedAt.utcString(),
            "isDeleted": deleted,
            "fields": enc_data // [UInt8]?
            ] as [String : Any]
        
        return dict
    }
    
    public static func from(dict:[String:Any]) -> Record {
        let currentUser = Global.shared.currentUser
        
        let record = Record()
        record.id = dict["id"] as! String
        record.title = dict["title"] as! String
        record.tags = (dict["tags"] as? String) ?? ""
        record.createdBy = dict["createdBy"] as! String
        record.createdAt = Utils.dateFrom(string: dict["createdAt"] as! String)!
        record.updatedAt = Utils.dateFrom(string: dict["updatedAt"] as! String)!
        record.ts = Utils.dateFrom(string: dict["ts"] as! String)!
        record.titleUpdatedAt = Utils.dateFrom(string: dict["titleUpdatedAt"] as! String)!
        record.tagsUpdatedAt = Utils.dateFrom(string: dict["tagsUpdatedAt"] as! String)!
        record.isDeleted = dict["isDeleted"] as! Int
        record.isSynced = true
        record.isDirty = false
        
        let fields = dict["fields"] as! [UInt8]
        let fieldsBytes = AppEncryptor.decryptAES256(cipheredBytes: fields, key: (currentUser?.accountKey)!)
        let fieldsArray = Utils.arrayFrom(jsonData: Data(bytes: fieldsBytes!)) as! [[String:Any]]
        
        for item in fieldsArray {
            let field = Field.from(dict: item)
            record.fields.append(field)
        }
        
        return record
    }
    
    public func resetSyncStatus() {
        self.isDirty = false
        self.isSynced = true
        for field in self.fields {
            field.resetSyncStatus()
        }
    }
}
