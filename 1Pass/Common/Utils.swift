//
//  Utils.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import CRNotifications
import CoreImage
import CryptoSwift
import KeychainSwift
import RealmSwift

class Utils: NSObject {
    
    //Byte array to string
    public class func convertToString(bytes:[UInt8]) -> String {
//        let data = Data(bytes: bytes)
//        return data.toString()
        
        let data = NSData(bytes: bytes, length: Int(bytes.count))
        let base64String = data.base64EncodedString(options: .lineLength64Characters)
        return base64String
    }
    
    public class func convertToData(bytes:[UInt8]) -> Data {
        return Data(bytes: bytes)
    }
    
    public class func isNetworkConnected() -> Bool {
        return NetworkAvailability.reachabilityForInternetConnection().isReachable()
    }
    
    public class func showError(title: String!, message: String!, dismissDelay:TimeInterval = 20) {
        CRNotifications.showNotification(type: .error, title: title, message: message, dismissDelay: dismissDelay)
    }
    
    public class func isObjectNotNil(_ object:AnyObject?) -> Bool
    {
        if object is NSNull {
            return false
        }
        
        if let _:AnyObject = object
        {
            return true
        }
        
        return false
    }
    
    public class func getString(_ input:Any) -> String {
        let strInput = input as? String
        if Utils.isObjectNotNil(strInput as AnyObject) {
            return strInput!
        } else {
            return ""
        }
    }
    
    public class func getDictionary(_ input:Any) -> [String:Any] {
        let dictInput = input as? [String:Any]
        if Utils.isObjectNotNil(dictInput as AnyObject) {
            return dictInput!
        } else {
            return [:]
        }
    }
    
    public class func getArray(_ input:Any) -> [Any] {
        let arrInput = input as? [Any]
        if Utils.isObjectNotNil(arrInput as AnyObject) {
            return arrInput!
        } else {
            return []
        }
    }
    
    public class func getBoolean(_ input:Any) -> Bool {
        let boolInput = input as? Bool
        if Utils.isObjectNotNil(boolInput as AnyObject) {
            return boolInput!
        } else {
            return false
        }
    }
    
    public class func getInt(_ input:Any) -> Int {
        let intInput = input as? Double
        if Utils.isObjectNotNil(intInput as AnyObject) {
            return Int(intInput!)
        } else {
            let intInput2 = input as? Int
            if Utils.isObjectNotNil(intInput2 as AnyObject) {
                return Int(intInput2!)
            }
            return 0
        }
    }
    
    public class func getInt64(_ input:Any) -> Int64 {
        let intInput = input as? Double
        if Utils.isObjectNotNil(intInput as AnyObject) {
            return Int64(intInput!)
        }
        
        let intInput2 = input as? Int64
        if Utils.isObjectNotNil(intInput2 as AnyObject) {
            return Int64(intInput2!)
        }
        
        let intInput3 = input as? Int
        if Utils.isObjectNotNil(intInput3 as AnyObject) {
            return Int64(intInput3!)
        }
        return 0
    }
    
    public class func getDouble(_ input:Any) -> Double {
        let doubleInput = input as? Double
        if Utils.isObjectNotNil(doubleInput as AnyObject) {
            return doubleInput!
        } else {
            let doubleInput2 = input as? Int
            if Utils.isObjectNotNil(doubleInput2 as AnyObject) {
                return Double(doubleInput2!)
            }
            return 0.0
        }
    }
    
    public class func substringFrom(originalString:String , fromIndex: Int) -> String {
        if fromIndex > originalString.count {
            return ""
        }
        let index = originalString.index(originalString.startIndex, offsetBy: fromIndex)
        return String(originalString.suffix(from: index))
    }
    
    public class func substringInRange(_ mainString:String, _ fromIndex:Int, _ length:Int) -> String {
        if(fromIndex < 0 || (fromIndex + length) >= mainString.count ) {
            return ""
        }
        let start = String.Index(encodedOffset: fromIndex)
        let end = String.Index(encodedOffset: fromIndex + length)
        return String(mainString[start..<end]) // "012345"
    }
    
    public class func substringFromIndex(_ fromIndex:Int, toIndex:Int, _ mainString:String) -> String {
        if((fromIndex < 0) || (fromIndex > toIndex) ) {
            return ""
        }
        let start = String.Index(encodedOffset: fromIndex)
        let end = String.Index(encodedOffset: toIndex + 1)
        return String(mainString[start..<end])
    }
    
    public class func firstIndexOf(_ subString:String, foundIn mainString:String) -> Int {
        if let range: Range<String.Index> = mainString.range(of: subString) {
            return mainString.distance(from: mainString.startIndex, to: range.lowerBound)
        }
        return -1
    }
    
    public class func matches(for regex: String, in text: String) -> Bool { // e.g: regex: "[0-9]" or "(123|456|333)$"
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            let arr:[String] = results.map {
                String(text[Range($0.range, in: text)!])
            }
            return (arr.isEmpty ? false : true)
        } catch let error {
            DDLog("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    public class func rgbColor(_ red:Int, _ green:Int, _ blue:Int, _ alpha:Double=1.0) -> UIColor {
        return UIColor(red: CGFloat(Double(red)/255.0), green: CGFloat(Double(green)/255.0), blue: CGFloat(Double(blue)/255.0), alpha: CGFloat(alpha))
    }
    
    public class func isValidEmail(_ email:String) -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil
    }
    
    // MARK: App Flow
    public static func generateWalletPassword(length: Int) -> String {
        let lowercase = "abcdefghijklmnopqrstuvwxyz"
        let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let number = "0123456789"
        let specialChar = "!@#$%^&*()_-=+{}['~`]|;:,./?><"
        
        var allowedChars = ""
        allowedChars += lowercase
        allowedChars += specialChar
        allowedChars += uppercase
        allowedChars += number
        
        // Generate Random Value from allowedChars
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    public static func generateWalletPrivateKey() -> String {
        let lowercase = "abcdefghijkmnopqrstuvwxyz"
        let uppercase = "ABCDEFGHJKLMNPQRSTUVWXYZ"
        let number = "123456789"
        
        var allowedChars = ""
        allowedChars += lowercase
        allowedChars += uppercase
        allowedChars += number
        
        // Generate Random Value from allowedChars
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = "5" // start with the number 5 on mainnet (9 on testnet)
        
        for _ in 0..<50 { // length is 51
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    public static func addRecordToShortcut(recordID:String) {
        let df = UserDefaults.standard
        var shortcut = df.stringArray(forKey: Keys.shortcut)
        if shortcut != nil {
            // Remove existing record id
            if let index = shortcut?.index(of: recordID) {
                shortcut!.remove(at: index)
            }
            // Add record id again
            shortcut?.append(recordID)
        } else {
            shortcut = [recordID]
        }
        df.set(shortcut, forKey: Keys.shortcut)
    }
    
    public static func removeRecordFromShortcut(recordID:String) {
        let df = UserDefaults.standard
        var shortcut = df.stringArray(forKey: Keys.shortcut)
        if shortcut != nil {
            // Remove existing record id
            if let index = shortcut?.index(of: recordID) {
                shortcut!.remove(at: index)
            }
            df.set(shortcut, forKey: Keys.shortcut)
        }
    }
    
    public static func getRecordsFromShortcut() -> [String] {
        let df = UserDefaults.standard
        return (df.stringArray(forKey: Keys.shortcut) ?? [])
    }
    
    public static func isPad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }
    
    public static func saveSettingsAutoLockApp(after:Float) {
        let df = UserDefaults.standard
        df.set(after, forKey: Settings.Auto_Lock_After)
    }
    
    public static func getSettingsAutoLockApp() -> Float {
        let df = UserDefaults.standard
        var after = df.object(forKey: Settings.Auto_Lock_After) as? Float
        after = after ?? Float(5.0) // default is 5 minutes
        return after!
    }
    
    public static func renameDatabase() {
        let username = Global.shared.currentUser?.username
        do {
            let oldFileURL = Realm.Configuration.defaultConfiguration.fileURL
            let newFileURL = oldFileURL?.deletingLastPathComponent().appendingPathComponent("\(username!).realm")
            
            try FileManager.default.moveItem(at: oldFileURL!, to: newFileURL!)
        } catch {
            Utils.showError(title: "Cannot rename local database.", message: "")
        }
    }
    
    public static func saveCustomServer(info:[String:String]) {
        let df = UserDefaults.standard
        df.set(info, forKey: Keys.customServerInfo)
    }
    
    public static func getCustomServerInfo() -> Any? {
        let df = UserDefaults.standard
        return df.object(forKey: Keys.customServerInfo)
    }
    
    public static func saveSetupStatus() {
        let df = UserDefaults.standard
        df.set(true, forKey: Keys.setupStatus)
        
    }
    
    public static func currentSetupStatus() -> Bool {
        let df = UserDefaults.standard
        return df.bool(forKey: Keys.setupStatus)
    }
    
    
    public static func saveSyncMethod(_ method: SyncMethod) {
        let df = UserDefaults.standard
        df.set(method.rawValue, forKey: Keys.syncMethod)
        
    }
    
    public static func currentSyncMethod() -> SyncMethod {
        let df = UserDefaults.standard
        if let method = df.object(forKey: Keys.syncMethod) {
            return SyncMethod(rawValue: method as! Int)!
        } else {
            return SyncMethod.offline
        }
    }
    
    public static func getValidFields(record:Record) -> [Field] {
        var result = [Field]()
        for item in record.fields {
            if item.isDeleted == 0 {
                result.append(item)
            }
        }
        return result
    }
    
    public static func getTotalField(record:Record) -> Int {
        var count = 0
        for item in record.fields {
            if item.isDeleted == 0 {
                count += 1
            }
        }
        
        return count
    }
    
    public static func dateFrom(string:String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConfig.DateTimeFormat
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from:string)
    }
    public static func removeCredentialsFromDisk() {
        let df = UserDefaults.standard
        df.removeObject(forKey: Keys.credentials)
        
    }
    
    public static func saveToDisk(credentials:[String:Any]) {
        let df = UserDefaults.standard
        df.set(credentials, forKey: Keys.credentials)
        
    }
    
    public static func saveInKeychain(secretKey:String, user:User!) {
        DDLog("secretKey: \(secretKey)")
        DispatchQueue(label: "saveInKeychain").async {
            autoreleasepool {
                let passwordData = user.masterPassword.toData()
                let theKey = try? PKCS5.PBKDF2(password: (passwordData.bytes), salt: (passwordData.bytes), iterations: 1, variant: .sha256).calculate()
                guard let enc_secretKey = AppEncryptor.encryptAES256(plainData: secretKey.bytes, key: theKey!) else {
                    DDLog("Error: saveInKeychain. private key is nil")
                    return
                }
            
                let keychain = KeychainSwift()
                keychain.synchronizable = true
                let key = Keys.secretKey + "_" + (user.username)!
                if  keychain.set(Data(bytes: enc_secretKey), forKey: key) {
                    DDLog("Private Key is saved successfully.")
                } else {
                    DDLog("Error: saveInKeychain private key.")
                }
            }
        }
    }
    
    public static func checkIfPrivateKeyAvailable(forUsername:String) -> Bool {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        let key = Keys.secretKey + "_" + forUsername
        guard keychain.getData(key) != nil else {
            return false
        }
        return true
    }
    
    public static func getSecretKey() -> String? {
        let currentUser = Global.shared.currentUser
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        let key = Keys.secretKey + "_" + (currentUser?.username)!
        guard let enc_secretKey = keychain.getData(key) else {
            return nil
        }
        
        let passwordData = currentUser?.masterPassword.toData()
        let theKey = try? PKCS5.PBKDF2(password: (passwordData?.bytes)!, salt: (passwordData?.bytes)!, iterations: 1, variant: .sha256).calculate()
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: enc_secretKey.bytes, key: theKey!)
        
        if decrypted != nil {
            return (Data(bytes: decrypted!)).toString()
        }
        return nil
    }
    
    public static func arrayFrom(jsonData:Data) -> [Any] {
        do {
            let array =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any]
            if array != nil {
                return array!
            }
        } catch _ as NSError {
            return []
        }
        return []
    }
    
}
