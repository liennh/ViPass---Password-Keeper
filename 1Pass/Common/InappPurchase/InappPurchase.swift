//
//  InappPurchase.swift
//  1Pass
//
//  Created by Ngo Lien on 8/22/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit

/*
 General Flow:
 - SignUp -> Update expiredAt in local (Free Trial)
 - Cloud tab, Sync: -> Update expiredAt in local (Free Trial)
 - SignIn -> Update expiredAt in local
 
 - Purchase -> Update expiredAt in local and server
 - Restore ->  Update expiredAt in local
 
 - MainVC open: ->
 + Read expiredAt from local. check if to unlock or allow sync.
 + In background Call API to Update expiredAt in local.(server always win)
 if expired,
     refresh/fetch receipt.
     if success:
        update expiredAt on local and server.
     else:
        do nothing
 else:
    update local with result from API
 
 */

class InappPurchase: NSObject {
    
    public static func setAccountType(_ type:Int) {
        guard type >= 0 else {
            return
        }
        let df = UserDefaults.standard
        df.set(type, forKey: Keys.accountType)
    }
    
    public static func getAccountType() -> Int {
        let df = UserDefaults.standard
        if let type = df.value(forKey: Keys.accountType) {
            return type as! Int // Premium
        }
        return 0 // default is Free Trial
    }
    
    public static func getLocalExpiredAt() -> Date {
        let currentUser = Global.shared.currentUser
        let accountKey = (currentUser?.accountKey)!
        let df = UserDefaults.standard
        let enc_expiredAt = df.array(forKey: Keys.enc_expiredAt) as! [UInt8]
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: enc_expiredAt, key: accountKey)
        let stringDate = (Data(bytes: decrypted!)).toString()
        return Utils.dateFrom(string: stringDate)!
    }
    
    public static func updateLocal(expiredAt: Date) {
        let currentUser = Global.shared.currentUser
        let accountKey = (currentUser?.accountKey)!
        
        let stringDate = expiredAt.utcString()
        let enc_expiredAt = AppEncryptor.encryptAES256(plainData: stringDate.bytes, key: accountKey)
        let df = UserDefaults.standard
        df.set(enc_expiredAt, forKey: Keys.enc_expiredAt)
    }
    
    /*
     let params = [Keys.i: username,
     Keys.enc_expiredAt: enc_expiredAt // encrypted Date String
     ] as [String: Any]
     */
    public static func updateServer(expiredAt: Date) {
        let currentUser = Global.shared.currentUser
        let stringDate = expiredAt.utcString()
        let enc_expiredAt = AppEncryptor.encryptAES256(plainData: stringDate.bytes, key: (currentUser?.sessionKey)!)
        let params = [Keys.i: (currentUser?.username)!,
                      Keys.enc_expiredAt: enc_expiredAt!] as [String : Any]
        
        // APICompletion block is run right after get response from server
        let completedBlock = { (_ succeeded: Bool, _ data:[String:Any]?) -> Void in
        }
        
        APIHandler.sharedInstance.makeRequest(APIs.updateSubscriptionExpiredAt, method: .post, parameters: params, completion: completedBlock)
    }
    
    public static func refreshServerExpiredAt() {
        guard Utils.isNetworkConnected() else {
            DDLog("No Internet Connection.")
            return
        }
        
        let currentUser = Global.shared.currentUser
        let params = [Keys.i: (currentUser?.username)!] as [String : Any]
        
        // APICompletion block is run right after get response from server
        let completedBlock = { (_ succeeded: Bool, _ data:[String:Any]?) -> Void in
            if succeeded {
                let userAccounting = data![Keys.user_accounting] as! [String:Any]
                let accountType = userAccounting[Keys.accountType] as! Int
                let expiredAt = userAccounting[Keys.expiredAt] as! String
                let expiredDate = Utils.dateFrom(string: expiredAt)
                InappPurchase.updateLocal(expiredAt: expiredDate!)
                InappPurchase.setAccountType(accountType)
                let now = Date()
                if expiredDate! <= now {
                    InappPurchase.refreshReceipt()
                }
            }
        }
        
        APIHandler.sharedInstance.makeRequest(APIs.getSubscriptionExpiredAt, method: .post, parameters: params, completion: completedBlock)
    }
    
    /*
     Verify Subscription
     This can be used to check if a subscription was previously purchased, and whether it is still active or if it's expired.
    */
    public static func refreshReceipt() {
        let sharedSecret = AppConfig.Inapp_Purchase_Shared_Secret
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) { result in
            switch result {
            case .success(let receipt):
                let productId = AppConfig.Yearly_Subscription_Product_ID
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    DDLog("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    InappPurchase.setAccountType(1) // Premium
                    InappPurchase.updateLocal(expiredAt: expiryDate)
                    InappPurchase.updateServer(expiredAt: expiryDate)
                case .expired(let expiryDate, let items):
                    DDLog("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    InappPurchase.setAccountType(1) // Premium
                    InappPurchase.updateLocal(expiredAt: expiryDate)
                    InappPurchase.updateServer(expiredAt: expiryDate)
                case .notPurchased:
                    DDLog("The user has never purchased \(productId)")
                }
                
            case .error(let error):
                DDLog("Receipt verification failed: \(error)")
            }
        }
    }

} // end class
