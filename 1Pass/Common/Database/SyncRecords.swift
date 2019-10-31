//
//  Sync.swift
//  ViPass
//
//  Created by Ngo Lien on 6/5/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import RealmSwift

class SyncRecords:NSObject {

    public static func syncWithServer() {
        guard Utils.isNetworkConnected() else {
            DDLog("No Internet Connection.")
            return
        }
        
        guard (Utils.currentSyncMethod() == SyncMethod.vipass) ||
            (Utils.currentSyncMethod() == SyncMethod.custom)  else {
            return
        }
        
        let expiryDate = InappPurchase.getLocalExpiredAt()
        let now = Date()
        
        guard expiryDate > now else {
            return
        }
        
        SyncRecords.start()
    }
    
    public static func start() {
        guard Global.shared.currentUser != nil else {
            DDLog("Current User is nil.")
            return
        }
        
        DispatchQueue(label: "SyncRecordsInBackground").async {
            autoreleasepool {
                SyncRecords.downloadServerChanges()
                guard Global.shared.allowSync else {
                    return
                }
                SyncRecords.uploadClientChanges()
            }
        }
    }
    
    /*
     /******* Download server changes **********/
     For each sync table:
     1. Get the latest Ts, e.g. using sqlite “select ifnull(ts, 0) from Table order by ts desc limit 1”
     
     2. Call API to get server changes since lastSyncedAt Date()
     
     /* Insert or update the received changes into local storage */
     3. Iterate through each record in the server changes collection
         - If the local storage doesn’t have the server record and server record is deleted:
            + continue
     
         - If the local storage doesn’t have the server record and server record is NOT deleted:
            + Insert into Local
         - If server record is deleted:
            + remove local record
         - If local record.isDeleted == -1 // deleted locally
            + call api to delete server record with id. (isDeleted = 1 and ts = Date())
            + remove local record
     
         - If local record is NOT dirty:
            + Replace local record with server record
     
         - If local record is dirty:
            + Result Record <- merge local record with server record
            + Put Result Record on server (ts = Date())
            + Reset the dirty flag and Put Result Record on local
    */
    public static func downloadServerChanges() {
        
        guard Utils.isNetworkConnected() else {
            DDLog("No Internet Connection.")
            return
        }
        
        guard (Utils.currentSyncMethod() == SyncMethod.vipass) ||
            (Utils.currentSyncMethod() == SyncMethod.custom)  else {
                return
        }
        
        var isRunning = true
        Global.shared.allowSync = true
        repeat {
            guard Global.shared.currentUser != nil else {
                DDLog("Current User is nil.")
                return
            }
            DDLog("Start downloadServerChanges: isRunning: True")
            // 1. Get the latest Ts. Date
            let maxTs = SyncRecords.lastSyncedAt()
            
            // 2. Call API to get server changes since lastSyncedAt Date()
            SyncRecords.getLatestRecordChangesOnServer(sinceTs: maxTs) { (records, error) in
                if records != nil {
                    // No Error
                    let count = records!.count
                    if count > 0 {
                        // 3. Iterate through each record in the server changes collection
                        SyncRecords.mergeIntoLocal(serverChanges: records!)
                        if count < AppConfig.Max_Items_Per_Download_Request {
                            DDLog("Count < Max_Items_Per_Download_Request: isRunning: False")
                            isRunning = false
                        }
                        
                    } else {
                        // no error and no records to get (server.ts > max local.ts)
                        DDLog("no errors and no records to fetch from server: isRunning: False")
                        isRunning = false
                    }
                } else {
                    // If network error, try again
                    DDLog("Network error. Try again. It seems server is down.")
                    isRunning = false
                    Global.shared.allowSync = false
                }
            }
            
        } while isRunning
        DDLog("Finish downloadServerChanges: isRunning: \(isRunning)")
        
    }// func downloadServerChanges
    
    
    /*
     /******* Upload client changes **********/
     For each sync table:
    
     1. Get the list of local storage changes for deleting on the server (isDeleted == -1)
     - DELETE list of records on server. (isDeleted = 1)
     - Reset the dirty flag for all inserted records
     
     2. Get the list of local storage changes for updating on the server (isDirty == true)
     Get list of server records by [IDs]
     Iterate through each record in the local changes for updates
     + Map records by ID
     + Result Record <- merge local record with server record
     + Put Result Record on server
     + Reset the dirty flag and Put Result Record on local
     
     3. Get the list of local storage changes for inserting on the server. (isSynced = false AND isDeleted = 0)
     - POST list of records on server (insert)
     - Reset the dirty flag for all inserted records
     
    */
    public static func uploadClientChanges() {
        // 1. Get the list of local storage changes for deleting on the server (isSynced = true AND isDeleted = -1)
        DDLog("Start uploadClientChanges: isRunning: true")
        var isRunning = true
        repeat {
            guard Global.shared.currentUser != nil else {
                DDLog("Current User is nil.")
                return
            }
            DDLog("Start getRecordsDeletedLocally: isRunning: true")
            if let recordsDeletedLocally = SyncRecords.getRecordsDeletedLocally(),
                recordsDeletedLocally.count > 0 {
                SyncRecords.deleteOnServer(bulkRecords: recordsDeletedLocally) { (status, error) in
                    if status == true {
                        // When completed, remove them from local
                        for record in recordsDeletedLocally {
                            SyncRecords.removeFromLocal(record: record)
                        }
                    } else {
                        // If network error, try again
                        DDLog("Network error. Try again")
                        isRunning = true
                    }
                }
            } else { // error or no records to upload
                DDLog("Local error or No records to upload.")
                isRunning = false
            }
        } while isRunning
        DDLog("End getRecordsDeletedLocally: isRunning: \(isRunning)")
        
        // 2. Get the list of local storage changes for updating on the server (isSynced = true AND isDirty = true)
        isRunning = true
        repeat {
            guard Global.shared.currentUser != nil else {
                DDLog("Current User is nil.")
                return
            }
            DDLog("Start getRecordsChangedLocally: isRunning: \(isRunning)")
            if let dirtyRecords = SyncRecords.getRecordsChangedLocally(),
                dirtyRecords.count > 0 {
                
                SyncRecords.uploadRecordsChangedLocally(records: dirtyRecords) { (status, error) in
                    if status == true {
                        // When completed, Reset the dirty flag for all inserted records
                        let realm = try! Realm()
                        realm.beginWrite()
                        // Update record if it already exists, add it if not.
                        for record in dirtyRecords {
                            record.resetSyncStatus()
                            realm.add(record, update: true)
                        }
                        try! realm.commitWrite()
                    } else {
                        // If network error, try again
                        DDLog("Network error. Try again")
                        isRunning = true
                    }
                }
            } else { // error or no records to upload
                DDLog("Local error or No records to upload")
                isRunning = false
            }
        } while isRunning
        DDLog("End getRecordsChangedLocally: isRunning: \(isRunning)")
        
        // 3. isSynced = false AND isDeleted = 0
        isRunning = true
        repeat {
            guard Global.shared.currentUser != nil else {
                DDLog("Current User is nil.")
                return
            }
            DDLog("Start getRecordsNotSyncedYet: isRunning: \(isRunning)")
            if let notSyncedRecords = SyncRecords.getRecordsNotSyncedYet(),
                notSyncedRecords.count > 0 {
                
                SyncRecords.uploadNotSynced(records: notSyncedRecords) { (status, error) in
                    if status == true {
                        // When completed, Reset the dirty flag for all inserted records
                        let realm = try! Realm()
                        realm.beginWrite()
                        // Update record if it already exists, add it if not.
                        for record in notSyncedRecords {
                            record.resetSyncStatus()
                            realm.add(record, update: true)
                        }
                        try! realm.commitWrite()
                    } else {
                        // If network error, try again
                        DDLog("Network error. Try again")
                        isRunning = true
                    }
                }
            } else { // error or no records to upload
                DDLog("Local error or No records to upload")
                isRunning = false
            }
        } while isRunning
        DDLog("End getRecordsNotSyncedYet: isRunning: \(isRunning)")
        
        DDLog("Finish uploadClientChanges: isRunning: \(isRunning)")
    }// func uploadClientChanges
    
    // MARK: Calling API Sync
   /* public static func getServerRecord(id:String, block:@escaping RecordBlock) {
        let currentUser = Global.shared.currentUser
        let enc_recordID = AppEncryptor.encryptAES256(plainData: id.bytes, key: (currentUser?.sessionKey)!)
        
        let params = [Keys.i: (currentUser?.username)!,
                      Keys.recordID: enc_recordID!
            ] as [String: Any]
        // Send request to server
        APIHandler.sharedInstance.makeSyncRequest(APIs.getRecordByID, method: .post, parameters: params, completion: {(_ succeeded: Bool, _ data:[String:Any]) -> Void in
            if succeeded {
                let recordDict = data[Keys.record] as! [String:Any]
                let record = Record.from(dict: recordDict)
                block(record, nil)
            } else {
                let error = data[Keys.error] ?? "Error Occurred!"
                block(nil, error as? String)
            }
        })
    }*/
    
    public static func getLatestRecordChangesOnServer(sinceTs:Date, block:@escaping RecordsBlock) {
        guard let currentUser = Global.shared.currentUser else {
            return
        }
        
        let dateString = sinceTs.utcString()
        let enc_sinceTs = AppEncryptor.encryptAES256(plainData: dateString.bytes, key: (currentUser.sessionKey)!)

        let params = [Keys.i: (currentUser.username)!,
                      Keys.ts: enc_sinceTs!
            ] as [String: Any]
        // Send request to server
        APIHandler.sharedInstance.makeSyncRequest(APIs.getLatestRecordChanges, method: .post, parameters: params, completion: {(_ succeeded: Bool, _ data:[String:Any]) -> Void in
            
            if succeeded {
                let changes = data[Keys.listRecords] as! [[String:Any]]
                var listRecords = [Record]()
                for item in changes {
                    let record = Record.from(dict: item)
                    listRecords.append(record)
                }
                block(listRecords, nil)
            } else {
                let error = data[Keys.error] ?? "Error Occurred!"
                block(nil, error as? String)
            }
        })
    }
    
    // PUT mergedRecord on server
   /* public static func putOnServer(mergedRecord:Record, nextBlock:@escaping NextBlock) {
        let currentUser = Global.shared.currentUser
        mergedRecord.ts = Date()
        let dict = mergedRecord.toDictionary()
        let enc_record = AppEncryptor.encryptAES256(plainData: dict.json.bytes, key: (currentUser?.sessionKey)!)
        
        let params = [Keys.i: (currentUser?.username)!,
                      Keys.record: enc_record!
            ] as [String: Any]
        // Send request to server
        APIHandler.sharedInstance.makeSyncRequest(APIs.updateRecord, method: .put, parameters: params, completion: {(_ succeeded: Bool, _ data:[String:Any]?) -> Void in
            if succeeded {
                nextBlock()
            } else {
                // do nothing here
            }
        })
    }*/
    
    // call api to delete on server record with id. (isDeleted = 1)
    /*public static func deleteOnServer(record:Record, nextBlock:@escaping NextBlock) {
        let currentUser = Global.shared.currentUser
        record.isDeleted = 1 // deleted on server
        record.ts = Date()
        
        let dict = [
            "id": record.id,
            "ts": record.ts!.utcString(), // ts cannot nil here
            "isDeleted": record.isDeleted
            ] as [String : Any]
        
        let enc_record = AppEncryptor.encryptAES256(plainData: dict.json.bytes, key: (currentUser?.sessionKey)!)
        
        let params = [Keys.i: (currentUser?.username)!,
                      Keys.record: enc_record!
            ] as [String: Any]
        // Send request to server
        APIHandler.sharedInstance.makeSyncRequest(APIs.updateRecord, method: .put, parameters: params, completion: {(_ succeeded: Bool, _ data:[String:Any]?) -> Void in
            if succeeded {
                nextBlock()
            } else {
                // do nothing here
            }
        })
    }*/
    
    public static func deleteOnServer(bulkRecords recordsDeletedLocally:[Record], block:@escaping BoolBlock) {
        let currentUser = Global.shared.currentUser
        var listRecords = [String]()
        for record in recordsDeletedLocally {
            record.ts = Date()
            listRecords.append(record.toDictionary().json)
        }
        let bulk = "[\(listRecords.joined(separator: ","))]"
        let enc_records = AppEncryptor.encryptAES256(plainData: bulk.bytes, key: (currentUser?.sessionKey)!)
        let params = [Keys.i: (currentUser?.username)!,
                      Keys.bulkRecords: enc_records!
            ] as [String: Any]
        // Send request to server
        APIHandler.sharedInstance.makeSyncRequest(APIs.deleteBulkRecords, method: .post, parameters: params, completion: {(_ succeeded: Bool, _ data:[String:Any]) -> Void in
            if succeeded {
                block(true, nil)
            } else {
                let error = data[Keys.error] ?? "Error Occurred!"
                block(false, error as? String)
            }
        })
    }
    
    public static func uploadNotSynced(records notSyncedRecords:[Record], block:@escaping BoolBlock) {
        let currentUser = Global.shared.currentUser
        var listRecords = [String]()
        for record in notSyncedRecords {
            record.ts = Date()
            listRecords.append(record.toDictionary().json)
        }
        let bulk = "[\(listRecords.joined(separator: ","))]"
        let enc_records = AppEncryptor.encryptAES256(plainData: bulk.bytes, key: (currentUser?.sessionKey)!)
        let params = [Keys.i: (currentUser?.username)!,
                      Keys.bulkRecords: enc_records!
                      ] as [String: Any]

        // Send request to server
        APIHandler.sharedInstance.makeSyncRequest(APIs.uploadNotSyncedRecords, method: .post, parameters: params, completion: {(_ succeeded: Bool, _ data:[String:Any]) -> Void in
            if succeeded {
                block(true, nil)
            } else {
                let error = data[Keys.error] ?? "Error Occurred!"
                block(false, error as? String)
            }
        })
    }
    
    public static func uploadRecordsChangedLocally(records dirtyRecords:[Record], block:@escaping BoolBlock) {
        let currentUser = Global.shared.currentUser
        var listRecords = [String]()
        for record in dirtyRecords {
            record.ts = Date()
            listRecords.append(record.toDictionary().json)
        }
        let bulk = "[\(listRecords.joined(separator: ","))]"
        let enc_records = AppEncryptor.encryptAES256(plainData: bulk.bytes, key: (currentUser?.sessionKey)!)
        let params = [Keys.i: (currentUser?.username)!,
                      Keys.bulkRecords: enc_records!
            ] as [String: Any]
        
        // Send request to server
        APIHandler.sharedInstance.makeSyncRequest(APIs.updateBulkRecords, method: .post, parameters: params, completion: {(_ succeeded: Bool, _ data:[String:Any]) -> Void in
            if succeeded {
                block(true, nil)
            } else {
                let error = data[Keys.error] ?? "Error Occurred!"
                block(false, error as? String)
            }
        })
    }
    
    
    // MARK: Sync Func updateBulkRecords
    public static func mergeIntoLocal(serverChanges:[Record]) {
        for server in serverChanges {
            let local = AppDB.getRecord(id: server.id)
            
            if (local == nil) && (server.isDeleted != 0) {
                continue
            }
            
            if (local?.ts == server.ts) && (local?.isDirty == false) {
                continue
            }
            
            // Record not found in local and server record is NOT deleted
            if (local == nil) && (server.isDeleted == 0) {
                // Insert into Local
                SyncRecords.insertIntoLocal(serverRecord: server)
                continue
            }
            
            // local record found and server record is deleted
            if server.isDeleted != 0 {
                // remove local record
                SyncRecords.removeFromLocal(record: local!)
                continue
            }
            
            if local?.isDirty == false {
                // + Replace local record with server record
                SyncRecords.replace(local: local!, with: server)
                continue
            }
            
            // Record is deleted locally
           /* if local?.isDeleted == -1 {
                // call api to delete server record with id. (isDeleted = 1)
                SyncRecords.deleteOnServer(record: server) {
                    // When completed, remove local record
                    SyncRecords.removeFromLocal(record: local!)
                }
                continue
            }*/
            
            if local?.isDirty == true {
                // + Result Record <- merge local record with server record
                let mergedRecord = SyncRecords.mergeRecords(local: local!, server: server)
                // Update mergedRecord in local
                SyncRecords.replace(local: local!, with: mergedRecord!)
                continue
            }
            
        }// for
    }// func mergeIntoLocal
    
    public static func replace(local:Record, with server:Record) {
        let recordID = server.id
        let shouldRemoveIndex = (local.title != server.title) ||
            (local.tags != server.tags)
        let localCopy = local.copy() as! Record
        let serverCopy = server.copy() as! Record
        AppDB.update(record: server) {(status, error) in
            guard error == nil else {
                DDLog("Failed to update record. Record ID: \(recordID). Error: \(String(describing: error)))")
                return
            }
            if shouldRemoveIndex {
                RecordIndex.removeFromIndex(record: localCopy) { (status, error) in
                    if error != nil {
                        DDLog("Failed to remove record from Index. Record ID: \(recordID). Error: \(String(describing: error))")
                    }
                    RecordIndex.addToIndex(record: serverCopy) { (status, error) in
                        if error != nil {
                            DDLog("Failed to add record to Index. Record ID: \(recordID). Error: \(String(describing: error))")
                        }
                    }
                }
            }
        }
    }
    
    public static func removeFromLocal(record:Record) {
        let recordID = record.id
        var realm:Realm?
        do { // Get realm and table instances for this thread. You only need to do this once (per thread)
            realm = try Realm()
            // Delete an object with a transaction
            try realm?.write {
                //realm.delete(record) // ok if record is a realm object (added, not a copy)
                let object = realm?.objects(Record.self).filter("id=%@", record.id)
                realm?.delete(object!)
            }
            
            // Remove from Index
            RecordIndex.removeFromIndex(record: record) { (status, error) in
                if error != nil {
                    DDLog("Failed to remove record from index. Record ID: \(recordID). Error: \(String(describing: error))")
                }
            }
        } catch let error as NSError {
            // handle error
            DDLog("Failed to remove record from local. Record ID: \(recordID). Error: \(String(describing: error.localizedDescription))")
        }
    }
    
    public static func insertIntoLocal(serverRecord:Record) {
        let indexRecord = serverRecord.copy() as! Record
        let recordID = serverRecord.id
        AppDB.save(record: serverRecord) { (status, error) in
            guard error == nil else {
                DDLog("Failed to save record in local. Record ID: \(recordID). Error: \(String(describing: error))")
                return
            }
            // If save ok, add record to Index for Full Text Search
            RecordIndex.addToIndex(record: indexRecord) { (status, error) in
                guard error == nil else {
                    DDLog("Failed to add record to Index. Record ID: \(recordID). Error: \(String(describing: error))")
                    return
                }
            }
        }
    }
    
    // MARK: Intecract with Database
    public static func lastSyncedAt() -> Date {
        var realm:Realm?
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            realm = try Realm()
            let allRecords = realm?.objects(Record.self).sorted(byKeyPath: Keys.ts, ascending: false)
            guard let ts = allRecords?.first?.ts else {
                return Date(timeIntervalSince1970: 1) // 1 second after 00:00:00 UTC on 1 January 1970
            }
           
            return ts
        } catch let error as NSError {
            // handle error
            DDLog("Error: \(error.localizedDescription)")
            return Date(timeIntervalSince1970: 1) // 1 second after 00:00:00 UTC on 1 January 1970
        }
    }
    
    public static func getRecordsNotSyncedYet() -> [Record]?  {
        var realm:Realm?
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            realm = try Realm()
            // Get records not synced with server
            let records = realm?.objects(Record.self).filter("isSynced = false AND isDeleted = 0")
            var list = [Record]()
            var count = records?.count
            if count! > AppConfig.Max_Items_Per_Upload_Request {
                count = AppConfig.Max_Items_Per_Upload_Request // limit number of records per a sync time
            }
            for i in 0..<count! {
                let copy = (records![i]).copy() as! Record
                list.append(copy)
            }
            if list.count == 0 {
                return nil
            }
            return list
        } catch let error as NSError {
            // handle error
           
            DDLog("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    public static func getRecordsDeletedLocally() -> [Record]?  {
        var realm:Realm?
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            realm = try Realm()
            // Get records deleted locally
            let records = (realm?.objects(Record.self).filter("isSynced = true AND isDeleted = -1"))
           
            var list = [Record]()
            var count = records?.count
            if count! > AppConfig.Max_Items_Per_Upload_Request {
                count = AppConfig.Max_Items_Per_Upload_Request // limit number of records per a sync time
            }
            for i in 0..<count! {
                let copy = (records![i]).copy() as! Record
                list.append(copy)
            }
            if list.count == 0 {
                return nil
            }
            return list
        } catch let error as NSError {
            // handle error
         
            DDLog("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    public static func getRecordsChangedLocally() -> [Record]?  {
        var realm:Realm?
        do {// Get realm and table instances for this thread. You only need to do this once (per thread)
            realm = try Realm()
            // Get records deleted locally
            let records = realm?.objects(Record.self).filter("isSynced = true AND isDirty = true")
            
            var list = [Record]()
            var count = records?.count
            if count! > AppConfig.Max_Items_Per_Upload_Request {
                count = AppConfig.Max_Items_Per_Upload_Request // limit number of records per a sync time
            }
            for i in 0..<count! {
                let copy = (records![i]).copy() as! Record
                list.append(copy)
            }
            if list.count == 0 {
                return nil
            }
            return list
        } catch let error as NSError {
            // handle error
            DDLog("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: Merge Data
    public static func mergeRecords(local:Record, server:Record) -> Record? {
        guard local.id == server.id else {
            return nil
        }
        // Init result with unchanged properties
        let result = Record()
        result.id = server.id
        result.createdBy = server.createdBy
        result.createdAt = server.createdAt
        result.isDirty = true
        result.isSynced = true
        result.ts = server.ts
        
        
        // Check updatedAt
        if local.updatedAt < server.updatedAt {
            result.updatedAt = server.updatedAt
        } else {
            result.updatedAt = local.updatedAt
        }
        
        // Init
        result.isDeleted = 0 // not deleted
    
        // local is deleted. Deletion always win
        if (local.isDeleted != 0) {
            result.isDeleted = local.isDeleted
            //return result // ignore other properties
        }
        
        // Check Record Title
        if local.title == server.title {
            result.title = server.title
            result.titleUpdatedAt = server.titleUpdatedAt
        } else if local.titleUpdatedAt < server.titleUpdatedAt {
            result.title = server.title
            result.titleUpdatedAt = server.titleUpdatedAt
        } else {
            result.title = local.title
            result.titleUpdatedAt = local.titleUpdatedAt
        }
        
        // Check Record Tags
        if local.tags == server.tags {
            result.tags = server.tags
            result.tagsUpdatedAt = server.tagsUpdatedAt
        } else if local.tagsUpdatedAt < server.tagsUpdatedAt {
            result.tags = server.tags
            result.tagsUpdatedAt = server.tagsUpdatedAt
        } else {
            result.tags = local.tags
            result.tagsUpdatedAt = local.tagsUpdatedAt
        }
        
        // Check Fields
        var index = -1
        var resultFields = [Field]()
        resultFields.append(contentsOf: server.fields.map {($0).copy() as! Field} )

        for localField in local.fields {
            var serverField:Field? = nil
            for i in 0..<resultFields.count {
                let item:Field = resultFields[i]
                if item.id == localField.id {
                    serverField = item
                    index = i
                    break
                }
            }// for
            
            // Local field does not appear in server fields
            if serverField == nil {
                resultFields.append(localField.copy() as! Field)
            } else {
                // merge 2 fields
                if let mergedField = SyncRecords.mergeFields(local: localField, server: serverField!) {
                    resultFields[index] = mergedField
                }
            }
        }// for
        
        result.fields.append(objectsIn: resultFields)
        return result
    }
    
    public static func mergeFields(local:Field, server:Field) -> Field? {
        guard local.id == server.id else {
            return nil
        }
        // Init result with unchanged properties
        let result = Field()
        result.id = server.id
        result.isSynced = true
        
        // local is deleted or server is deleted. Deletion always win
        if (local.isDeleted != 0) || (server.isDeleted != 0) {
            result.isDeleted = 1
            result.name = ""
            result.value = ""
            return result // ignore other properties
        }
        
        result.isDeleted = 0 // not deleted
        
        // Check Field Name
        if local.name == server.name {
            result.name = server.name
            result.nameUpdatedAt = server.nameUpdatedAt
        } else if local.nameUpdatedAt < server.nameUpdatedAt {
            result.name = server.name
            result.nameUpdatedAt = server.nameUpdatedAt
        } else {
            result.name = local.name
            result.nameUpdatedAt = local.nameUpdatedAt
        }
        
        // Check Field Value
        if local.value == server.value {
            result.value = server.value
            result.valueUpdatedAt = server.valueUpdatedAt
        } else if local.valueUpdatedAt < server.valueUpdatedAt {
            result.value = server.value
            result.valueUpdatedAt = server.valueUpdatedAt
        } else {
            result.value = local.value
            result.valueUpdatedAt = local.valueUpdatedAt
        }
        
        return result
    }

}// class
