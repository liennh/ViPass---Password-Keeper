//
//  AppDB.swift
//  1Pass
//
//  Created by Ngo Lien on 5/26/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import RealmSwift

class AppDB:NSObject {
    
    // MARK: Add
    public static func saveInBackground(record:Record!, block:BoolBlock?) {
        DispatchQueue(label: "saveInBackground").async {
            autoreleasepool {
                do {// Get realm and table instances for this thread. You only need to do this once (per thread)
                    let realm = try Realm()
                    // Add to the Realm inside a transaction
                    try realm.write {
                        realm.add(record)
                    }
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(true, nil)
                        }
                    }
                } catch let error as NSError {
                    // handle error
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(false, error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    public static func save(record:Record!, block:BoolBlock?) {
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            let realm = try Realm()
            // Add to the Realm inside a transaction
            try realm.write {
                realm.add(record)
            }
            if block != nil {
                DispatchQueue.main.async {
                    block!(true, nil)
                }
            }
        } catch let error as NSError {
            // handle error
            if block != nil {
                DispatchQueue.main.async {
                    block!(false, error.localizedDescription)
                }
            }
        }
    }
    
    // List of records should <= 1000 items
    public static func insertInBackground(records:[Record]!, block:BoolBlock?) {
        DispatchQueue(label: "insertInBackground").async {
            autoreleasepool {
                do { // Get realm and table instances for this thread. You only need to do this once (per thread)
                    let realm = try Realm()
                    realm.beginWrite()
                    for i in 0..<records.count {
                        realm.add(records[i])
                    }
                    // Commit the write transaction
                    // to make this data available to other threads
                    try realm.commitWrite()
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(true, nil)
                        }
                    }
                } catch let error as NSError {
                    // handle error
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(false, error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    // List of records should <= 1000 items
    public static func insertRecords(data:[[String:Any]]!, block:BoolBlock?) {
        DispatchQueue(label: "insertRecords").async {
            autoreleasepool {
                do { // Get realm and table instances for this thread. You only need to do this once (per thread)
                    let realm = try Realm()
                    realm.beginWrite()
                    for i in 0..<data.count {
                        // Add record via dictionary. Property order is ignored.
                        realm.create(Record.self, value: data[i])
                    }
                    // Commit the write transaction
                    // to make this data available to other threads
                    try realm.commitWrite()
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(true, nil)
                        }
                    }
                } catch let error as NSError {
                    // handle error
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(false, error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    public static func deleteInBackground(record:Record!, block:BoolBlock?) {
        DispatchQueue(label: "deleteInBackground").async {
            autoreleasepool {
                do { // Get realm and table instances for this thread. You only need to do this once (per thread)
                    let realm = try Realm()
                    // Delete an object with a transaction
                    try realm.write {
                        // realm.delete(record) // ok if record is a realm object (added, not a copy)
                        let object = realm.objects(Record.self).filter("id=%@", record.id)
                        realm.delete(object)
                    }
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(true, nil)
                        }
                    }
                } catch let error as NSError {
                    // handle error
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(false, error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Update
    public static func updateInBackground(record:Record!, block:BoolBlock?) {
        DispatchQueue(label: "updateInBackground").async {
            autoreleasepool {
                do { // Get realm and table instances for this thread. You only need to do this once (per thread)
                    let realm = try Realm()
                    // Update record if it already exists, add it if not.
                    try realm.write {
                        realm.add(record, update: true)
                    }
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(true, nil)
                        }
                    }
                } catch let error as NSError {
                    // handle error
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(false, error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    public static func update(record:Record!, block:BoolBlock?) {
        do { // Get realm and table instances for this thread. You only need to do this once (per thread)
            let realm = try Realm()
            // Update record if it already exists, add it if not.
            try realm.write {
                realm.add(record, update: true)
            }
            if block != nil {
                DispatchQueue.main.async {
                    block!(true, nil)
                }
            }
        } catch let error as NSError {
            // handle error
            if block != nil {
                DispatchQueue.main.async {
                    block!(false, error.localizedDescription)
                }
            }
        }
    }
    
    // var record = ["id": "UUID", "name": "Facebook", ... other fields]
    public static func updateRecordPartially(changes:[String:Any]!, block:BoolBlock?) {
        DispatchQueue(label: "updateRecordPartially").async {
            autoreleasepool {
                do { // Get realm and table instances for this thread. You only need to do this once (per thread)
                    let realm = try Realm()
                    // Update record if it already exists, add it if not.
                    try realm.write {
                        // Assuming a "Book" with a primary key of `1` already exists.
                        realm.create(Record.self, value: changes, update: true)
                        // the book's `title` property will remain unchanged.
                    }
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(true, nil)
                        }
                    }
                } catch let error as NSError {
                    // handle error
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(false, error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Get
    public static func getRecord(id:String!) -> Record? {
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            let realm = try Realm()
            guard let record = realm.object(ofType: Record.self, forPrimaryKey: id) else {
                return nil
            }
            return (record.copy() as! Record)
        } catch let error as NSError {
            // handle error
            DDLog("Failed to fetch record ID: \(id). Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    public static func getRecords(ids:[String]!) -> [Record]?  {
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            let realm = try Realm()
            // let joined = ids.joined(separator: ", ")
            var records = [Record]()
            for id in ids {
                if let object = realm.object(ofType: Record.self, forPrimaryKey: id) {
                    records.append(object)
                }
            }
            
            // let records = realm.objects(Record.self).filter("\(String(describing: Record.primaryKey())) IN {\(joined)}")
            return records
        } catch let error as NSError {
            // handle error
            DDLog("Failed to fetch list of record IDs: \(ids). Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    public static func getAllRecords() -> Results<Record>?  {
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            let realm = try Realm()
            // retrieves all Records from the default Realm
            let records = realm.objects(Record.self)
            return records
        } catch let error as NSError {
            // handle error
            DDLog("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    
}

