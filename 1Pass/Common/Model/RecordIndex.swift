//
//  RecordIndex.swift
//  1Pass
//
//  Created by Ngo Lien on 5/29/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import RealmSwift

public class RecordIndex:Object, NSCopying {
    @objc dynamic var id:String! // each id is a word
    @objc dynamic var recordsData:Data? // Both key and value is the id of record in table Record.
    var records: [String: String] {
        get {
            guard let recordsData = recordsData else {
                return [String: String]()
            }
            do {
                let dict = try JSONSerialization.jsonObject(with: recordsData, options: []) as? [String: String]
                return dict!
            } catch {
                return [String: String]()
            }
        }
        
        set {
            do {
                let data = try JSONSerialization.data(withJSONObject: newValue, options: [])
                recordsData = data
            } catch {
                recordsData = nil
            }
        }
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["records"]
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = RecordIndex()
        copy.id = self.id
        copy.records = self.records
        return copy
    }
    
    public static func searchableWords(record:Record) -> [String] {
        let str = record.title + " " + (record.tags ?? "")
        return RecordIndex.searchableWords(string: str)
    }
    
    public static func searchableWords(string:String) -> [String] {
        var str = string
        str = str.trim()
        str = str.replacingOccurrences(of: "  ", with: " ") // thay 2 dau cach = 1 dau cach
        str = str.lowercased()
        let words = str.components(separatedBy: .whitespaces)
        var smallWords = [String]()
        for item in words {
            if item.count == 2 {
                let str = String(item.prefix(1))
                smallWords.append(str)
            }
            if item.count == 3 {
                var str = String(item.prefix(1))
                smallWords.append(str)
                str = String(item.prefix(2))
                smallWords.append(str)
            }
            if item.count == 4 {
                var str = String(item.prefix(1))
                smallWords.append(str)
                str = String(item.prefix(2))
                smallWords.append(str)
                str = String(item.prefix(3))
                smallWords.append(str)
            }
            if item.count == 5 {
                var str = String(item.prefix(1))
                smallWords.append(str)
                str = String(item.prefix(2))
                smallWords.append(str)
                str = String(item.prefix(3))
                smallWords.append(str)
                str = String(item.prefix(4))
                smallWords.append(str)
            }
            if item.count == 6 {
                var str = String(item.prefix(1))
                smallWords.append(str)
                str = String(item.prefix(2))
                smallWords.append(str)
                str = String(item.prefix(3))
                smallWords.append(str)
                str = String(item.prefix(4))
                smallWords.append(str)
                str = String(item.prefix(5))
                smallWords.append(str)
            }
            if item.count == 7 {
                var str = String(item.prefix(1))
                smallWords.append(str)
                str = String(item.prefix(2))
                smallWords.append(str)
                str = String(item.prefix(3))
                smallWords.append(str)
                str = String(item.prefix(4))
                smallWords.append(str)
                str = String(item.prefix(5))
                smallWords.append(str)
                str = String(item.prefix(6))
                smallWords.append(str)
            }
            if item.count == 8 {
                var str = String(item.prefix(1))
                smallWords.append(str)
                str = String(item.prefix(2))
                smallWords.append(str)
                str = String(item.prefix(3))
                smallWords.append(str)
                str = String(item.prefix(4))
                smallWords.append(str)
                str = String(item.prefix(5))
                smallWords.append(str)
                str = String(item.prefix(6))
                smallWords.append(str)
                str = String(item.prefix(7))
                smallWords.append(str)
            }
        }// for
        
        let keywords = words + smallWords
        var dict = [String:String]()
        for item in keywords {
            dict[item] = item
        }
        let uniqueWords = dict.keys
        return Array(uniqueWords)
    }
    
    public static func recordsFor(searchable:[String]!, block:RecordsBlock?) {
        DispatchQueue(label: "RecordIndex").async {
            autoreleasepool {
                do {// Get realm and table instances for this thread. You only need to do this once (per thread)
                    let realm = try Realm()
                    var recordIDs = [String]()
                    for item in searchable {
                        if let recordIndex = realm.object(ofType: RecordIndex.self, forPrimaryKey: item) {
                            recordIDs.append(contentsOf: Array(recordIndex.records.keys))
                        }
                    }
                    var uniqueIDs = [String:Int]() // key: Score
                    for id in recordIDs {
                        if let score = uniqueIDs[id] {
                            uniqueIDs[id] = score + 1
                        } else {
                            uniqueIDs[id] = 1
                        }
                    }
                    // Sort by score. DESC
                    let sortedKeys = uniqueIDs.keys.sorted{uniqueIDs[$0]! > uniqueIDs[$1]!}
                    let records = AppDB.getRecords(ids: sortedKeys)  // Results<Record>?
                    var results = [Record]()
                    if( (records != nil) && !(records?.isEmpty)! ) {
                        for record in records! {
                            let copy = record.copy() as! Record
                            results.append(copy)
                        }
                    }
                    
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(results, nil)
                        }
                    }
                } catch let error as NSError {
                    // handle error
                    if block != nil {
                        DispatchQueue.main.async {
                            block!(nil, error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    public static func addToIndexInBackground(record:Record!, block:BoolBlock?) {
        DispatchQueue(label: "RecordIndex").async {
            autoreleasepool {
                do {// Get realm and table instances for this thread. You only need to do this once (per thread)
                    let realm = try Realm()
                    let searchable = RecordIndex.searchableWords(record: record)
                    for item in searchable {
                        if let index = realm.object(ofType: RecordIndex.self, forPrimaryKey: item) {
                            // Update existing index
                            realm.beginWrite()
                            index.records[record.id] = record.id
                            try realm.commitWrite()
                        } else {
                            // Create new index
                            let index = RecordIndex()
                            index.id = item
                            index.records = [record.id:record.id]
                            // Add to the Realm inside a transaction
                            try realm.write {
                                //realm.add(index)
                                realm.add(index, update: true)
                            }
                        }
                    }// for
                    
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
    }// func addToIndexInBackground
    
    public static func addToIndex(record:Record!, block:BoolBlock?) {
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            let realm = try Realm()
            let searchable = RecordIndex.searchableWords(record: record)
            for item in searchable {
                if let index = realm.object(ofType: RecordIndex.self, forPrimaryKey: item) {
                    // Update existing index
                    realm.beginWrite()
                    index.records[record.id] = record.id
                    try realm.commitWrite()
                } else {
                    // Create new index
                    let index = RecordIndex()
                    index.id = item
                    index.records = [record.id:record.id]
                    // Add to the Realm inside a transaction
                    try realm.write {
                        //realm.add(index)
                        realm.add(index, update: true)
                    }
                }
            }// for
            
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
    }// func addToIndex
    
    public static func removeFromIndexInBackground(record:Record!, block:BoolBlock?) {
        DispatchQueue(label: "RecordIndex").async {
            autoreleasepool {
                do {// Get realm and table instances for this thread. You only need to do this once (per thread)
                    let realm = try Realm()
                    let searchable = RecordIndex.searchableWords(record: record)
                    for item in searchable {
                        if let index = realm.object(ofType: RecordIndex.self, forPrimaryKey: item) {
                            // Delete record from index
                            realm.beginWrite()
                            index.records.removeValue(forKey: record.id)
                            if index.records.isEmpty {
                                realm.delete(index)
                            }
                            try realm.commitWrite()
                        }
                    }// for
                    
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
    }// func removeFromIndexInBackground
    
    public static func removeFromIndex(record:Record!, block:BoolBlock?) {
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            let realm = try Realm()
            let searchable = RecordIndex.searchableWords(record: record)
            for item in searchable {
                if let index = realm.object(ofType: RecordIndex.self, forPrimaryKey: item) {
                    // Delete record from index
                    realm.beginWrite()
                    index.records.removeValue(forKey: record.id)
                    if index.records.isEmpty {
                        realm.delete(index)
                    }
                    try realm.commitWrite()
                }
            }// for
            
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
    }// func removeFromIndex
}// class RecordIndex

