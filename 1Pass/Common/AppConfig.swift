//
//  AppConfig.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

/***************  Closure  ***************/
public typealias  APICompletion = (_ succeeded: Bool, _ data:[String:Any]) -> Void
//public typealias  IdResultBlock = (_ result: Any?, _ error: NSError?) -> Void
public typealias  RecordsBlock = (_ result: [Record]?, _ error: String?) -> Void
public typealias  RecordBlock = (_ result: Record?, _ error: String?) -> Void
public typealias  BoolBlock = (_ status: Bool, _ error: String?) -> Void
public typealias  VoidBlock = () -> Void
public typealias  NextBlock = () -> Void

enum SyncMethod:Int {
    case offline = 0
    case vipass
    case custom // custom server
}

enum AccountType:Int {
    case free_trial = 0
    case premium
}

class AppConfig {
    static let BASE_API = "https://vipass.1pass.vn/api/v1/"//"http://178.128.0.137:8181/api/v1/" // "http://localhost:8181/api/v1/" 
    static let DateTimeFormat = "yyyy-MM-dd'T'HH:mm:ssZZ" // "yyyy-MM-dd HH:mm:ss" 
    static let SpecialChars = "!@#$%^&*()_-=+{}['~`]|;:,./?><"
    // At least 1 [A-Z], [a-z], [0-9], SpecialChars, length in 12 - 256
    static let password_rules = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_?/=+{}\\['~`]|;:,.?><]).{12,256}$"
    static let Max_Items_Per_Upload_Request = 100
    static let Max_Items_Per_Download_Request = 100
    static let local_username = "local"
    static let api_Key_value = "xvEuQ2WbF2QAb9AjOiBr1HSCa1GjkqU0" // Don't change it
    static let App_Name = "ViPass"
    static let Apple_ID = "1407697727"
    static let Yearly_Subscription_Product_ID = "vn.1pass.vipass.subscription.yearly"
    static let Inapp_Purchase_Shared_Secret = "eb7b028310d1439aab69e61271692415"
    static let freeTrialPeriod = 7 // days
    static let URL_Terms_Of_Use = "https://www.1pass.vn/apps/vipass/terms.html"
    static let URL_Privacy_Policy = "https://www.1pass.vn/apps/vipass/privacy.html"
    static let URL_White_Paper = "https://www.1pass.vn/apps/vipass/white-paper.html"
    static let URL_Website = "https://www.1pass.vn"
}
    
struct ErrorMsg {
    static let invalid_session_key = "Invalid session key."
    static let user_does_not_exist = "User does not exist."
    static let please_supply_values = "Please supply values."
    static let invalid_parameters = "Invalid parameters."
}

struct APIs {
    //static let getRecordByID = "getRecordByID"   // not used
    //static let updateRecord = "updateRecord"     // not used
    //static let insertRecord = "insertRecord"     // not used
    static let signUp = "signUp"
    static let loginFirstStep = "loginFirstStep"
    static let loginLastStep = "loginLastStep"
    static let getLatestRecordChanges = "getLatestRecordChanges"
    static let deleteBulkRecords = "deleteBulkRecords"
    static let uploadNotSyncedRecords = "uploadNotSyncedRecords"
    static let updateBulkRecords = "updateBulkRecords"
    static let changeUserPassword = "changeUserPassword"
    static let checkUserExists = "checkUserExists"
    static let updateSubscriptionExpiredAt = "updateSubscriptionExpiredAt"
    static let getSubscriptionExpiredAt = "getSubscriptionExpiredAt"
}

struct Constant {
    static let Button_Corner_Radius:CGFloat = 4.0
}

struct Settings {
    static let Auto_Lock_After = "Auto_Lock_After"
}

extension Notification.Name {
    static let appTimeout = Notification.Name("appTimeout")
    static let Add_New_Field = Notification.Name("Add_New_Field")
    static let Delete_Field = Notification.Name("Delete_Field")
    static let Delete_Record = Notification.Name("Delete_Record")
    static let Update_Record = Notification.Name("Update_Record")
    static let Add_Record = Notification.Name("Add_Record")
    static let Change_Record = Notification.Name("Change_Record")
    static let Change_Password = Notification.Name("Change_Password")
    
    // static let Change_Password = Notification.Name("Change_Password")
}


struct Keys {
    static let api_Key = "api-Key"
    static let status = "status"
    static let error = "error"
    static let index = "index"
    static let record = "record"
    static let s = "s" // salt
    static let v = "v" // verifier
    static let iv = "iv"
    static let authTag = "authTag"
    static let data = "data"
    static let aad = "aad"
    static let i = "i"
    static let A = "A"
    static let a = "a" // client private key
    static let B = "B"
    static let b = "b" // server private key
    static let K = "K" // Session Key
    static let M = "M"
    static let HAMK = "HAMK" // M2 message in SRP
    //static let pubKey = "pubKey" // user public key
    //static let enc_pk = "enc_pk" // encrypted user private key
    //static let enc_sv = "enc_sv" // encrypted Salt + Verifier
    static let enc_ak = "enc_ak" // encrypted user account key
    static let enc_ssk = "enc_ssk" // encrypted session key
    static let credentials = "credentials"
    static let secretKey = "secretKey" // Random UUID. stored in Keychain
    static let ts = "ts" // Date or timestamp used for syncing with server
    static let listRecords = "listRecords"
    static let bulkRecords = "bulkRecords"
    static let recordID = "recordID"
    static let syncMethod = "syncMethod"
    static let setupStatus = "setupStatus" // true or false. used for SyncMethods NOT "vipass"
    static let enc_s = "enc_s" // Encrypted salt.
    static let enc_v = "enc_v" // Encrypted verifier
    static let alreadyShownWelcome = "alreadyShownWelcome" // Used to show Welcome screen or not
    static let customServerInfo = "customServerInfo"
    static let customServerURL = "customServerURL"
    static let customServerAPIKey = "customServerAPIKey"
    static let exist = "exist" // Used for check if user exist
    static let shortcut = "shortcut"
    static let accountType = "accountType" // free_trial or premium
    static let expiredAt = "expiredAt"
    static let enc_expiredAt = "enc_expiredAt"
    static let user_accounting = "user_accounting"
}



