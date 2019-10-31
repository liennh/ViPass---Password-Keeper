//
//  Field.swift
//  ViPass
//
//  Created by Ngo Lien on 4/30/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import RealmSwift

class Field:Object, NSCopying {
    @objc dynamic var id = UUID().uuidString // never changed after set
    @objc dynamic var name:String! // encrypted
    @objc dynamic var value:String! // encrypted
    
    @objc dynamic var nameUpdatedAt:Date = Date()
    @objc dynamic var valueUpdatedAt:Date = Date()
    
    //  0: not deleted
    // -1: deleted locally. But not synced with server
    //  1: deleted on server
    @objc dynamic var isDeleted:Int = 0
    @objc dynamic var isSynced:Bool = false // false means just created on local. Not exist on server
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Field()
        copy.id = self.id
        copy.name = self.name
        copy.value = self.value
        copy.nameUpdatedAt = self.nameUpdatedAt
        copy.valueUpdatedAt = self.valueUpdatedAt
        copy.isDeleted = self.isDeleted
        copy.isSynced = self.isSynced
        return copy
    }
    
    // Convert into dictionary for sending request to server
    func toDictionary() -> [String:Any] {
        let dict = [
            "id": self.id,
            "name": self.name,
            "value": self.value,
            "nameUpdatedAt": self.nameUpdatedAt.utcString(),
            "valueUpdatedAt": self.valueUpdatedAt.utcString(),
            "isDeleted": self.isDeleted,
            "isSynced": self.isSynced
            ] as [String : Any]
        
        return dict
    }
    
    public static func from(dict:[String:Any]) -> Field {
        let field = Field()
        field.id = dict["id"] as! String
        field.name = dict["name"] as! String
        field.value = dict["value"] as! String
        field.nameUpdatedAt = Utils.dateFrom(string: dict["nameUpdatedAt"] as! String)!
        field.valueUpdatedAt = Utils.dateFrom(string: dict["valueUpdatedAt"] as! String)!
        field.isDeleted = dict["isDeleted"] as! Int
        field.isSynced = dict["isSynced"] as! Bool
        return field
    }
    
    public func resetSyncStatus() {
        self.isSynced = true
    }
}
