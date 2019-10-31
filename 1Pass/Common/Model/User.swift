//
//  User.swift
//  ViPass
//
//  Created by Ngo Lien on 5/9/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import RealmSwift

class User:NSObject, NSCopying {
    public var username:String! // No encryption, used for search
    public var masterPassword:String!
    public var secretKey:String!
    // Used to encrypt data for this user. Never changed after created at SignUp. On server, accountKey is encrypted by aesMasterKey
    public var accountKey:[UInt8]!
    
    //public var publicKey:[UInt8]! // Used to encrypt Team Key when adding new member into Team. On server, Public Key is not encrypted
    //public var privateKey:[UInt8]! // used to decrypt Team Key. On server, privateKey is encrypted by aesMasterKey
    
    public var sessionKey:[UInt8]! // Used to encrypt data transfered between client and server
    
    // This is computed property based on masterPassword + secretKey
    public var aesMasterKey:[UInt8]? = nil // used to encrypt data AES 256 GCM
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = User()
        copy.username = self.username
        copy.masterPassword = self.masterPassword
        copy.secretKey = self.secretKey
        copy.accountKey = self.accountKey
        copy.aesMasterKey = self.aesMasterKey
        
        //copy.publicKey = self.publicKey
        //copy.privateKey = self.privateKey
        
        return copy
    }
    
    init(username:String?, password:String?) {
        self.username = username
        self.masterPassword = password
    }
    
    convenience override init() {
        self.init(username: nil, password:nil)
    }
}
